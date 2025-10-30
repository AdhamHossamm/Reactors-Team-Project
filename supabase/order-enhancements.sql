-- ============================================================================
-- SUPABASE ORDER ENHANCEMENTS SQL SCRIPT
-- Ensures orders track buyers, sellers, and maintain complete audit trail
-- ============================================================================
--
-- IMPORTANT: This script handles mixed schema types (UUID and BIGINT)
-- - products.id and products.seller_id are UUID
-- - order_items.product_id is BIGINT (references products.id)
-- - order_items.seller_id is UUID (matches products.seller_id)
-- - All comparisons use ::text casting to handle type mismatches
--
-- ============================================================================

-- ============================================================================
-- Step 1: Add seller tracking to order_items
-- ============================================================================
-- This ensures we know which seller owns each product in an order
-- Note: seller_id uses UUID to match products.seller_id type

ALTER TABLE order_items 
ADD COLUMN IF NOT EXISTS seller_id UUID,
ADD COLUMN IF NOT EXISTS product_description TEXT,
ADD COLUMN IF NOT EXISTS product_image_url VARCHAR(500),
ADD COLUMN IF NOT EXISTS discount_applied DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS shipping_fee DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS item_total DECIMAL(10, 2);

-- Note: Not adding FK constraint for seller_id due to mixed schema types
-- Application should enforce referential integrity

-- Update existing order_items to populate seller_id from products
UPDATE order_items oi
SET seller_id = p.seller_id,
    product_description = p.description,
    product_image_url = p.image_url
FROM products p
WHERE oi.product_id::text = p.id::text
AND oi.seller_id IS NULL;

-- Add comments
COMMENT ON COLUMN order_items.seller_id IS 'The seller who owns the product';
COMMENT ON COLUMN order_items.product_description IS 'Product description snapshot at time of order';
COMMENT ON COLUMN order_items.product_image_url IS 'Product image snapshot at time of order';
COMMENT ON COLUMN order_items.discount_applied IS 'Discount amount applied to this item';
COMMENT ON COLUMN order_items.item_total IS 'Total for this item (price * quantity - discount + shipping)';

-- Create indexes for seller queries
CREATE INDEX IF NOT EXISTS idx_order_items_seller ON order_items(seller_id);
CREATE INDEX IF NOT EXISTS idx_order_items_created ON order_items(created_at DESC);

-- ============================================================================
-- Step 2: Add order metadata and tracking fields
-- ============================================================================

ALTER TABLE orders
ADD COLUMN IF NOT EXISTS buyer_name VARCHAR(200),
ADD COLUMN IF NOT EXISTS buyer_email VARCHAR(254),
ADD COLUMN IF NOT EXISTS order_notes TEXT,
ADD COLUMN IF NOT EXISTS cancelled_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS refunded_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS tracking_number VARCHAR(100),
ADD COLUMN IF NOT EXISTS carrier VARCHAR(50);

-- Add comments
COMMENT ON COLUMN orders.buyer_name IS 'Buyer name snapshot at time of order';
COMMENT ON COLUMN orders.buyer_email IS 'Buyer email snapshot at time of order';
COMMENT ON COLUMN orders.order_notes IS 'Special instructions or notes from buyer';
COMMENT ON COLUMN orders.tracking_number IS 'Shipping tracking number';
COMMENT ON COLUMN orders.carrier IS 'Shipping carrier (FedEx, UPS, USPS, etc)';

-- ============================================================================
-- Step 3: Create comprehensive order view with buyer and seller info
-- ============================================================================

CREATE OR REPLACE VIEW order_details_view AS
SELECT 
    o.id AS order_id,
    o.order_number,
    o.status,
    o.created_at AS order_date,
    o.updated_at AS last_updated,
    
    -- Buyer information
    o.user_id AS buyer_id,
    COALESCE(o.buyer_name, bu.username, bu.first_name || ' ' || bu.last_name) AS buyer_name,
    COALESCE(o.buyer_email, bu.email) AS buyer_email,
    o.phone AS buyer_phone,
    
    -- Shipping information
    o.shipping_address,
    o.shipping_city,
    o.shipping_state,
    o.shipping_zip,
    o.shipping_country,
    o.tracking_number,
    o.carrier,
    
    -- Financial information
    o.subtotal,
    o.tax,
    o.shipping_cost,
    o.total,
    o.payment_method,
    o.payment_status,
    
    -- Status timestamps
    o.shipped_at,
    o.delivered_at,
    o.cancelled_at,
    o.refunded_at,
    
    -- Order metadata
    o.order_notes,
    
    -- Aggregated order statistics
    COUNT(DISTINCT oi.id) AS total_items,
    COUNT(DISTINCT oi.seller_id) AS total_sellers,
    COUNT(DISTINCT oi.product_id) AS unique_products,
    SUM(oi.quantity) AS total_quantity

FROM orders o
LEFT JOIN users bu ON o.user_id::text = bu.id::text
LEFT JOIN order_items oi ON o.id = oi.order_id
GROUP BY 
    o.id, o.order_number, o.status, o.created_at, o.updated_at,
    o.user_id, o.buyer_name, o.buyer_email, bu.username, bu.first_name, 
    bu.last_name, bu.email, o.phone,
    o.shipping_address, o.shipping_city, o.shipping_state, o.shipping_zip, 
    o.shipping_country, o.tracking_number, o.carrier,
    o.subtotal, o.tax, o.shipping_cost, o.total, o.payment_method, 
    o.payment_status, o.shipped_at, o.delivered_at, o.cancelled_at,
    o.refunded_at, o.order_notes;

-- Grant access to the view
GRANT SELECT ON order_details_view TO authenticated;
GRANT SELECT ON order_details_view TO anon;

COMMENT ON VIEW order_details_view IS 'Comprehensive order view with buyer info and aggregated statistics';

-- ============================================================================
-- Step 4: Create order items view with buyer and seller details
-- ============================================================================

CREATE OR REPLACE VIEW order_items_details_view AS
SELECT 
    oi.id AS order_item_id,
    oi.order_id,
    o.order_number,
    o.status AS order_status,
    o.created_at AS order_date,
    
    -- Buyer information
    o.user_id AS buyer_id,
    COALESCE(o.buyer_name, bu.username) AS buyer_name,
    COALESCE(o.buyer_email, bu.email) AS buyer_email,
    
    -- Product information
    oi.product_id,
    oi.product_name,
    oi.product_sku,
    oi.product_description,
    oi.product_image_url,
    
    -- Seller information
    oi.seller_id,
    su.username AS seller_name,
    su.email AS seller_email,
    sp.business_name AS seller_business_name,
    
    -- Pricing information
    oi.price AS unit_price,
    oi.quantity,
    oi.discount_applied,
    oi.shipping_fee,
    oi.item_total,
    (oi.price * oi.quantity) AS subtotal_before_discount,
    
    -- Calculated totals
    COALESCE(oi.item_total, 
        (oi.price * oi.quantity) - COALESCE(oi.discount_applied, 0) + COALESCE(oi.shipping_fee, 0)
    ) AS calculated_item_total,
    
    -- Timestamps
    oi.created_at,
    o.shipped_at,
    o.delivered_at

FROM order_items oi
JOIN orders o ON oi.order_id = o.id
LEFT JOIN users bu ON o.user_id::text = bu.id::text
LEFT JOIN users su ON oi.seller_id::text = su.id::text
LEFT JOIN seller_profiles sp ON oi.seller_id::text = sp.user_id::text;

-- Grant access to the view
GRANT SELECT ON order_items_details_view TO authenticated;
GRANT SELECT ON order_items_details_view TO anon;

COMMENT ON VIEW order_items_details_view IS 'Detailed order items with buyer, seller, and product information';

-- ============================================================================
-- Step 5: Create seller orders view (for seller dashboard)
-- ============================================================================

CREATE OR REPLACE VIEW seller_orders_view AS
SELECT 
    oi.seller_id,
    su.username AS seller_name,
    sp.business_name AS seller_business_name,
    
    o.id AS order_id,
    o.order_number,
    o.status AS order_status,
    o.created_at AS order_date,
    
    -- Buyer information
    o.user_id AS buyer_id,
    COALESCE(o.buyer_name, bu.username) AS buyer_name,
    COALESCE(o.buyer_email, bu.email) AS buyer_email,
    
    -- Seller's items in this order
    COUNT(oi.id) AS seller_items_count,
    SUM(oi.quantity) AS seller_total_quantity,
    SUM(COALESCE(oi.item_total, oi.price * oi.quantity)) AS seller_order_total,
    
    -- Order details relevant to seller
    o.shipping_address,
    o.shipping_city,
    o.shipping_state,
    o.shipping_zip,
    o.shipping_country,
    o.phone AS buyer_phone,
    o.shipped_at,
    o.delivered_at,
    o.tracking_number,
    o.carrier

FROM order_items oi
JOIN orders o ON oi.order_id = o.id
LEFT JOIN users bu ON o.user_id::text = bu.id::text
LEFT JOIN users su ON oi.seller_id::text = su.id::text
LEFT JOIN seller_profiles sp ON oi.seller_id::text = sp.user_id::text
WHERE oi.seller_id IS NOT NULL
GROUP BY 
    oi.seller_id, su.username, sp.business_name,
    o.id, o.order_number, o.status, o.created_at,
    o.user_id, o.buyer_name, o.buyer_email, bu.username, bu.email,
    o.shipping_address, o.shipping_city, o.shipping_state, o.shipping_zip,
    o.shipping_country, o.phone, o.shipped_at, o.delivered_at,
    o.tracking_number, o.carrier;

-- Grant access to the view
GRANT SELECT ON seller_orders_view TO authenticated;

COMMENT ON VIEW seller_orders_view IS 'Orders grouped by seller for seller dashboard';

-- ============================================================================
-- Step 6: Create trigger to auto-log order status changes
-- ============================================================================

CREATE OR REPLACE FUNCTION log_order_status_change() 
RETURNS TRIGGER AS $$
BEGIN
    -- Only log if status actually changed
    IF (TG_OP = 'UPDATE' AND OLD.status IS DISTINCT FROM NEW.status) THEN
        INSERT INTO order_status_history (
            order_id,
            status,
            notes,
            changed_by_id,
            created_at
        ) VALUES (
            NEW.id,
            NEW.status,
            'Status changed from ' || COALESCE(OLD.status, 'null') || ' to ' || NEW.status,
            NULL,  -- Can be populated by application
            NOW()
        );
        
        -- Update timestamp fields based on status
        IF NEW.status = 'shipped' AND OLD.status != 'shipped' THEN
            NEW.shipped_at := NOW();
        ELSIF NEW.status = 'delivered' AND OLD.status != 'delivered' THEN
            NEW.delivered_at := NOW();
        ELSIF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
            NEW.cancelled_at := NOW();
        ELSIF NEW.status = 'refunded' AND OLD.status != 'refunded' THEN
            NEW.refunded_at := NOW();
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_log_order_status_change ON orders;

-- Create trigger
CREATE TRIGGER trigger_log_order_status_change
    BEFORE UPDATE ON orders
    FOR EACH ROW
    EXECUTE FUNCTION log_order_status_change();

COMMENT ON FUNCTION log_order_status_change IS 'Automatically logs order status changes to order_status_history';

-- ============================================================================
-- Step 7: Create trigger to calculate order item totals
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_order_item_total() 
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate item_total if not explicitly set
    IF NEW.item_total IS NULL THEN
        NEW.item_total := (NEW.price * NEW.quantity) 
                         - COALESCE(NEW.discount_applied, 0) 
                         + COALESCE(NEW.shipping_fee, 0);
    END IF;
    
    -- Populate seller_id from product if not set (with type casting for mixed schema)
    IF NEW.seller_id IS NULL AND NEW.product_id IS NOT NULL THEN
        SELECT seller_id INTO NEW.seller_id 
        FROM products 
        WHERE id::text = NEW.product_id::text;
    END IF;
    
    -- Populate product details from product if not set (with type casting for mixed schema)
    IF NEW.product_description IS NULL AND NEW.product_id IS NOT NULL THEN
        SELECT description, image_url 
        INTO NEW.product_description, NEW.product_image_url
        FROM products 
        WHERE id::text = NEW.product_id::text;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_calculate_order_item_total ON order_items;

-- Create trigger
CREATE TRIGGER trigger_calculate_order_item_total
    BEFORE INSERT OR UPDATE ON order_items
    FOR EACH ROW
    EXECUTE FUNCTION calculate_order_item_total();

COMMENT ON FUNCTION calculate_order_item_total IS 'Automatically calculates item_total and populates seller_id';

-- ============================================================================
-- Step 8: Create function to update order status safely
-- ============================================================================

CREATE OR REPLACE FUNCTION update_order_status(
    p_order_id BIGINT,
    p_new_status VARCHAR(20),
    p_tracking_number VARCHAR(100) DEFAULT NULL,
    p_carrier VARCHAR(50) DEFAULT NULL,
    p_notes TEXT DEFAULT NULL,
    p_changed_by_id BIGINT DEFAULT NULL
) RETURNS BOOLEAN AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_valid_transition BOOLEAN := TRUE;
BEGIN
    -- Get current status
    SELECT status INTO v_current_status
    FROM orders
    WHERE id = p_order_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;
    
    -- Validate status transitions
    -- pending -> processing, cancelled
    -- processing -> shipped, cancelled
    -- shipped -> delivered, refunded
    -- delivered -> refunded
    -- cancelled -> cannot change
    -- refunded -> cannot change
    
    IF v_current_status = 'cancelled' OR v_current_status = 'refunded' THEN
        RAISE EXCEPTION 'Cannot change status of % order', v_current_status;
    END IF;
    
    -- Update order
    UPDATE orders
    SET 
        status = p_new_status,
        tracking_number = COALESCE(p_tracking_number, tracking_number),
        carrier = COALESCE(p_carrier, carrier),
        updated_at = NOW()
    WHERE id = p_order_id;
    
    -- Log to history with custom notes if provided
    IF p_notes IS NOT NULL THEN
        INSERT INTO order_status_history (
            order_id, status, notes, changed_by_id, created_at
        ) VALUES (
            p_order_id, p_new_status, p_notes, p_changed_by_id, NOW()
        );
    END IF;
    
    RETURN TRUE;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Error updating order status: %', SQLERRM;
        RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION update_order_status IS 'Safely updates order status with validation and logging';

-- ============================================================================
-- Step 9: Create function to get order summary
-- ============================================================================

CREATE OR REPLACE FUNCTION get_order_summary(p_order_id BIGINT)
RETURNS TABLE (
    order_number VARCHAR,
    status VARCHAR,
    buyer_name TEXT,
    buyer_email TEXT,
    total_amount DECIMAL,
    total_items BIGINT,
    total_sellers BIGINT,
    order_date TIMESTAMP WITH TIME ZONE,
    status_history JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_number,
        o.status,
        COALESCE(o.buyer_name, u.username),
        COALESCE(o.buyer_email, u.email),
        o.total,
        COUNT(DISTINCT oi.id) AS total_items,
        COUNT(DISTINCT oi.seller_id) AS total_sellers,
        o.created_at,
        (
            SELECT json_agg(
                json_build_object(
                    'status', osh.status,
                    'notes', osh.notes,
                    'changed_at', osh.created_at,
                    'changed_by', chu.username
                ) ORDER BY osh.created_at DESC
            )
            FROM order_status_history osh
            LEFT JOIN users chu ON osh.changed_by_id::text = chu.id::text
            WHERE osh.order_id = o.id
        ) AS status_history
    FROM orders o
    LEFT JOIN users u ON o.user_id::text = u.id::text
    LEFT JOIN order_items oi ON o.id = oi.order_id
    WHERE o.id = p_order_id
    GROUP BY 
        o.order_number, o.status, o.buyer_name, o.buyer_email, 
        u.username, u.email, o.total, o.created_at, o.id;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_order_summary IS 'Returns comprehensive order summary with status history';

-- ============================================================================
-- Step 10: Update RLS policies for orders
-- ============================================================================

-- Enable RLS on order tables (if not already enabled)
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_status_history ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Buyers can view their own orders" ON orders;
DROP POLICY IF EXISTS "Sellers can view orders containing their products" ON orders;
DROP POLICY IF EXISTS "Buyers can view their order items" ON order_items;
DROP POLICY IF EXISTS "Sellers can view their order items" ON order_items;
DROP POLICY IF EXISTS "Users can view order status history for their orders" ON order_status_history;

-- Buyers can view their own orders
CREATE POLICY "Buyers can view their own orders"
ON orders FOR SELECT
TO authenticated
USING (user_id::text = auth.uid()::text);

-- Sellers can view orders that contain their products
CREATE POLICY "Sellers can view orders containing their products"
ON orders FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM order_items
        WHERE order_items.order_id = orders.id
        AND order_items.seller_id::text = auth.uid()::text
    )
);

-- Buyers can view their order items
CREATE POLICY "Buyers can view their order items"
ON order_items FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM orders
        WHERE orders.id = order_items.order_id
        AND orders.user_id::text = auth.uid()::text
    )
);

-- Sellers can view their order items
CREATE POLICY "Sellers can view their order items"
ON order_items FOR SELECT
TO authenticated
USING (seller_id::text = auth.uid()::text);

-- Users can view order status history for their orders (buyers and sellers)
CREATE POLICY "Users can view order status history for their orders"
ON order_status_history FOR SELECT
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM orders o
        LEFT JOIN order_items oi ON o.id = oi.order_id
        WHERE o.id = order_status_history.order_id
        AND (o.user_id::text = auth.uid()::text OR oi.seller_id::text = auth.uid()::text)
    )
);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check if new columns exist
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_schema = 'public'
AND table_name = 'order_items'
AND column_name IN ('seller_id', 'product_description', 'item_total', 'discount_applied');

-- Check views
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'public'
AND table_name IN ('order_details_view', 'order_items_details_view', 'seller_orders_view');

-- Check functions
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN ('log_order_status_change', 'calculate_order_item_total', 'update_order_status', 'get_order_summary');

-- Check triggers
SELECT trigger_name, event_manipulation, event_object_table
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table IN ('orders', 'order_items');

-- ============================================================================
-- COMPLETE! 
-- Orders now track buyers and sellers with complete audit trail
-- All order changes are logged automatically
-- Views provide comprehensive order details
-- ============================================================================

