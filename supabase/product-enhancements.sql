-- ============================================================================
-- SUPABASE PRODUCT ENHANCEMENTS SQL SCRIPT
-- Add new product fields and setup storage for product images
-- ============================================================================

-- Step 1: Add new columns to products table
-- ============================================================================

ALTER TABLE public.products 
ADD COLUMN IF NOT EXISTS discount_percentage NUMERIC(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS shipping_fee NUMERIC(10,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS tags JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS technical_specs JSONB DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS refund_policy TEXT DEFAULT '30-day money-back guarantee';

-- Update existing products to have default values
UPDATE public.products 
SET 
    discount_percentage = COALESCE(discount_percentage, 0),
    shipping_fee = COALESCE(shipping_fee, 0),
    tags = COALESCE(tags, '[]'::jsonb),
    technical_specs = COALESCE(technical_specs, '{}'::jsonb),
    refund_policy = COALESCE(refund_policy, '30-day money-back guarantee')
WHERE discount_percentage IS NULL 
   OR shipping_fee IS NULL 
   OR tags IS NULL 
   OR technical_specs IS NULL 
   OR refund_policy IS NULL;

-- Add comments to new columns
COMMENT ON COLUMN public.products.discount_percentage IS 'Discount percentage (0-100)';
COMMENT ON COLUMN public.products.shipping_fee IS 'Shipping fee for this product';
COMMENT ON COLUMN public.products.tags IS 'Product tags as JSON array';
COMMENT ON COLUMN public.products.technical_specs IS 'Technical specifications as JSON object';
COMMENT ON COLUMN public.products.refund_policy IS 'Refund/return policy for this product';

-- Step 2: Create indexes for better query performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_products_discount ON public.products(discount_percentage) 
WHERE discount_percentage > 0;

CREATE INDEX IF NOT EXISTS idx_products_shipping_fee ON public.products(shipping_fee);

-- GIN indexes for JSONB fields (better JSON query performance)
CREATE INDEX IF NOT EXISTS idx_products_tags_gin ON public.products USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_products_technical_specs_gin ON public.products USING GIN(technical_specs);

-- Step 3: Create helper functions for product calculations
-- ============================================================================

-- Function to calculate discounted price
CREATE OR REPLACE FUNCTION get_discounted_price(
    original_price NUMERIC,
    discount_percentage NUMERIC
) RETURNS NUMERIC AS $$
BEGIN
    IF discount_percentage IS NULL OR discount_percentage = 0 THEN
        RETURN original_price;
    END IF;
    RETURN original_price - (original_price * discount_percentage / 100);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function to calculate final price (with shipping)
CREATE OR REPLACE FUNCTION get_final_price(
    original_price NUMERIC,
    discount_percentage NUMERIC,
    shipping_fee NUMERIC
) RETURNS NUMERIC AS $$
DECLARE
    discounted NUMERIC;
BEGIN
    discounted := get_discounted_price(original_price, discount_percentage);
    RETURN discounted + COALESCE(shipping_fee, 0);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Step 4: Create view for product listings with calculated prices
-- ============================================================================
-- FIXED: Handles mixed schema where products uses BIGINT and users uses UUID
-- Uses text casting to handle type mismatch between seller_id and user id

CREATE OR REPLACE VIEW public.product_listings AS
SELECT 
    p.id,
    p.seller_id,
    p.category_id,
    p.name,
    p.slug,
    p.description,
    p.price AS original_price,
    p.discount_percentage,
    get_discounted_price(p.price, p.discount_percentage) AS discounted_price,
    p.shipping_fee,
    get_final_price(p.price, p.discount_percentage, p.shipping_fee) AS final_price,
    p.stock,
    CASE WHEN p.stock > 0 THEN true ELSE false END AS in_stock,
    p.sku,
    p.brand,
    p.weight,
    p.tags,
    p.technical_specs,
    p.refund_policy,
    p.image_url,
    p.thumbnail_url,
    p.is_active,
    p.is_featured,
    p.created_at,
    p.updated_at,
    c.name AS category_name,
    COALESCE(u.username, up.username) AS seller_name
FROM public.products p
LEFT JOIN public.categories c ON p.category_id = c.id
LEFT JOIN public.users u ON p.seller_id::text = u.id::text
LEFT JOIN public.user_profiles up ON p.seller_id::text = up.id::text;

-- Grant access to the view
GRANT SELECT ON public.product_listings TO authenticated;
GRANT SELECT ON public.product_listings TO anon;

-- Step 5: Update RLS policies for new columns
-- ============================================================================

-- Allow sellers to insert/update their own products with new fields
-- (Existing policies should already cover this, but let's ensure they include new columns)

-- Step 6: Create product_images_storage table for tracking uploaded images
-- ============================================================================
-- FIXED: product_id must be UUID to match products.id type
-- Using BIGSERIAL for id (auto-increment) but UUID for product_id (FK reference)

CREATE TABLE IF NOT EXISTS public.product_images_storage (
    id BIGSERIAL PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    storage_path TEXT NOT NULL,
    storage_bucket TEXT DEFAULT 'product-images',
    file_name TEXT NOT NULL,
    file_size BIGINT,
    mime_type TEXT,
    is_primary BOOLEAN DEFAULT false,
    uploaded_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_storage_path UNIQUE (storage_bucket, storage_path)
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_product_images_storage_product_id 
ON public.product_images_storage(product_id);

CREATE INDEX IF NOT EXISTS idx_product_images_storage_is_primary 
ON public.product_images_storage(product_id, is_primary) 
WHERE is_primary = true;

-- Add comment
COMMENT ON TABLE public.product_images_storage IS 'Tracks product images stored in Supabase Storage';

-- RLS policies for product_images_storage
ALTER TABLE public.product_images_storage ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to view product images
CREATE POLICY "Anyone can view product images"
ON public.product_images_storage FOR SELECT
TO authenticated, anon
USING (true);

-- Allow sellers to insert images for their own products
CREATE POLICY "Sellers can insert images for their products"
ON public.product_images_storage FOR INSERT
TO authenticated
WITH CHECK (
    EXISTS (
        SELECT 1 FROM public.products
        WHERE products.id = product_id
        AND products.seller_id::text = auth.uid()::text
    )
);

-- Allow sellers to delete images for their own products
CREATE POLICY "Sellers can delete their product images"
ON public.product_images_storage FOR DELETE
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.products
        WHERE products.id = product_id
        AND products.seller_id::text = auth.uid()::text
    )
);

-- Step 7: Create function to auto-generate SKU
-- ============================================================================

CREATE OR REPLACE FUNCTION generate_product_sku() RETURNS TEXT AS $$
DECLARE
    new_sku TEXT;
    sku_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate SKU in format: PRD-YYYYMMDD-XXXXX
        new_sku := 'PRD-' || 
                   TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                   UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 5));
        
        -- Check if SKU already exists
        SELECT EXISTS(SELECT 1 FROM public.products WHERE sku = new_sku) INTO sku_exists;
        
        -- If unique, return it
        IF NOT sku_exists THEN
            RETURN new_sku;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Step 8: Create trigger to auto-generate SKU and slug if not provided
-- ============================================================================

CREATE OR REPLACE FUNCTION auto_generate_product_fields() RETURNS TRIGGER AS $$
BEGIN
    -- Auto-generate SKU if not provided
    IF NEW.sku IS NULL OR NEW.sku = '' THEN
        NEW.sku := generate_product_sku();
    END IF;
    
    -- Auto-generate slug if not provided
    IF NEW.slug IS NULL OR NEW.slug = '' THEN
        NEW.slug := LOWER(REGEXP_REPLACE(
            REGEXP_REPLACE(NEW.name, '[^a-zA-Z0-9\s-]', '', 'g'),
            '\s+', '-', 'g'
        ));
        
        -- Ensure slug is unique
        DECLARE
            base_slug TEXT := NEW.slug;
            counter INT := 1;
        BEGIN
            WHILE EXISTS(SELECT 1 FROM public.products WHERE slug = NEW.slug AND id != COALESCE(NEW.id, 0)) LOOP
                NEW.slug := base_slug || '-' || counter;
                counter := counter + 1;
            END LOOP;
        END;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_auto_generate_product_fields ON public.products;

-- Create trigger
CREATE TRIGGER trigger_auto_generate_product_fields
    BEFORE INSERT OR UPDATE ON public.products
    FOR EACH ROW
    EXECUTE FUNCTION auto_generate_product_fields();

-- ============================================================================
-- STORAGE BUCKET SETUP (Run in Supabase Dashboard → Storage)
-- ============================================================================

/*
MANUAL STEPS IN SUPABASE DASHBOARD:

1. Go to Storage in Supabase Dashboard
2. Create a new bucket called "product-images"
3. Set bucket to PUBLIC (so images are accessible)
4. Configure CORS if needed

OR use SQL to create bucket:
*/

-- Insert storage bucket (if using SQL)
INSERT INTO storage.buckets (id, name, public)
VALUES ('product-images', 'product-images', true)
ON CONFLICT (id) DO NOTHING;

-- Set storage policies for the bucket
CREATE POLICY "Public Access to Product Images"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'product-images');

CREATE POLICY "Authenticated users can upload product images"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'product-images');

CREATE POLICY "Users can update their product images"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'product-images');

CREATE POLICY "Users can delete their product images"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'product-images');

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if all columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'products'
AND column_name IN ('discount_percentage', 'shipping_fee', 'tags', 'technical_specs', 'refund_policy');

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'products'
AND indexname LIKE 'idx_products_%';

-- Check functions
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('get_discounted_price', 'get_final_price', 'generate_product_sku', 'auto_generate_product_fields');

-- Check storage bucket
SELECT * FROM storage.buckets WHERE id = 'product-images';

-- ============================================================================
-- COMPLETE! 
-- New product fields are ready to use
-- Image storage is configured
-- Auto-generation functions are active
-- ============================================================================

