-- ============================================================================
-- CHECKOUT PROCESS SYNCHRONIZATION SQL SCRIPT
-- Ensures checkout process syncs between Django and Supabase
-- ============================================================================
--
-- IMPORTANT: This script handles mixed schema types (UUID and BIGINT)
-- - orders.id is UUID (Supabase native)
-- - users.id is UUID (Supabase Auth)
-- - products.id is UUID
-- - cart_items.product_id is BIGINT (references products.id via text cast)
-- - All JOINs and comparisons use ::text casting to handle type mismatches
--
-- FIXED: Changed process_checkout return type from BIGINT to UUID for order_id
--
-- ============================================================================

-- Step 1: Update Order model to support Cash on Delivery
-- ============================================================================

-- Add cash_on_delivery as valid payment method
DO $$ 
BEGIN
    -- Check if payment_method column needs updating
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'orders' 
        AND column_name = 'payment_method'
    ) THEN
        -- Add constraint if not exists
        ALTER TABLE public.orders 
        DROP CONSTRAINT IF EXISTS orders_payment_method_check;
        
        ALTER TABLE public.orders 
        ADD CONSTRAINT orders_payment_method_check 
        CHECK (payment_method IN ('card', 'cash_on_delivery', 'paypal', 'bank_transfer'));
    END IF;
END $$;

-- Update existing orders to have default payment method
UPDATE public.orders 
SET payment_method = COALESCE(payment_method, 'cash_on_delivery')
WHERE payment_method IS NULL OR payment_method = '';

-- Step 2: Create checkout validation function
-- ============================================================================

CREATE OR REPLACE FUNCTION validate_checkout_order(
    p_user_id UUID,
    p_shipping_address TEXT,
    p_shipping_city TEXT,
    p_shipping_state TEXT,
    p_shipping_zip TEXT,
    p_phone TEXT
) RETURNS BOOLEAN AS $$
DECLARE
    cart_items_count INT;
BEGIN
    -- Check if user has items in cart (with type casting for mixed schema)
    SELECT COUNT(*) INTO cart_items_count
    FROM public.cart_items ci
    JOIN public.carts c ON ci.cart_id = c.id
    WHERE c.user_id::text = p_user_id::text;
    
    IF cart_items_count = 0 THEN
        RAISE EXCEPTION 'Cart is empty';
    END IF;
    
    -- Validate shipping information
    IF p_shipping_address IS NULL OR p_shipping_address = '' THEN
        RAISE EXCEPTION 'Shipping address is required';
    END IF;
    
    IF p_shipping_city IS NULL OR p_shipping_city = '' THEN
        RAISE EXCEPTION 'City is required';
    END IF;
    
    IF p_shipping_state IS NULL OR p_shipping_state = '' THEN
        RAISE EXCEPTION 'State is required';
    END IF;
    
    IF p_shipping_zip IS NULL OR p_shipping_zip = '' THEN
        RAISE EXCEPTION 'ZIP code is required';
    END IF;
    
    IF p_phone IS NULL OR p_phone = '' THEN
        RAISE EXCEPTION 'Phone number is required';
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Step 3: Create function to calculate order totals
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_order_totals(
    p_user_id UUID
) RETURNS TABLE (
    subtotal NUMERIC(10,2),
    tax NUMERIC(10,2),
    shipping_cost NUMERIC(10,2),
    total NUMERIC(10,2)
) AS $$
DECLARE
    v_subtotal NUMERIC(10,2);
    v_tax NUMERIC(10,2);
    v_shipping NUMERIC(10,2);
    v_total NUMERIC(10,2);
    tax_rate NUMERIC(5,4) := 0.10; -- 10% tax
BEGIN
    -- Calculate subtotal from cart (with type casting for mixed schema)
    SELECT COALESCE(SUM(p.price * ci.quantity), 0) INTO v_subtotal
    FROM public.cart_items ci
    JOIN public.carts c ON ci.cart_id = c.id
    JOIN public.products p ON ci.product_id::text = p.id::text
    WHERE c.user_id::text = p_user_id::text;
    
    -- Calculate tax (10%)
    v_tax := v_subtotal * tax_rate;
    
    -- Shipping cost (FREE for now, but can be based on location/weight)
    v_shipping := 0.00;
    
    -- Calculate total
    v_total := v_subtotal + v_tax + v_shipping;
    
    RETURN QUERY SELECT v_subtotal, v_tax, v_shipping, v_total;
END;
$$ LANGUAGE plpgsql;

-- Step 4: Create function to process checkout
-- ============================================================================

CREATE OR REPLACE FUNCTION process_checkout(
    p_user_id UUID,
    p_shipping_address TEXT,
    p_shipping_city TEXT,
    p_shipping_state TEXT,
    p_shipping_zip TEXT,
    p_shipping_country TEXT,
    p_phone TEXT,
    p_payment_method TEXT DEFAULT 'cash_on_delivery'
) RETURNS TABLE (
    order_id UUID,
    order_number TEXT,
    total_amount NUMERIC(10,2)
) AS $$
DECLARE
    v_order_id UUID;
    v_order_number TEXT;
    v_subtotal NUMERIC(10,2);
    v_tax NUMERIC(10,2);
    v_shipping NUMERIC(10,2);
    v_total NUMERIC(10,2);
    cart_item RECORD;
BEGIN
    -- Validate checkout
    PERFORM validate_checkout_order(
        p_user_id, 
        p_shipping_address, 
        p_shipping_city, 
        p_shipping_state, 
        p_shipping_zip, 
        p_phone
    );
    
    -- Calculate totals
    SELECT * INTO v_subtotal, v_tax, v_shipping, v_total
    FROM calculate_order_totals(p_user_id);
    
    -- Generate order number
    v_order_number := 'ORD-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NOW()::TEXT) FROM 1 FOR 12));
    
    -- Create order
    INSERT INTO public.orders (
        user_id,
        order_number,
        status,
        subtotal,
        tax,
        shipping_cost,
        total,
        shipping_address,
        shipping_city,
        shipping_state,
        shipping_zip,
        shipping_country,
        phone,
        payment_method,
        payment_status,
        created_at,
        updated_at
    ) VALUES (
        p_user_id,
        v_order_number,
        'pending',
        v_subtotal,
        v_tax,
        v_shipping,
        v_total,
        p_shipping_address,
        p_shipping_city,
        p_shipping_state,
        p_shipping_zip,
        p_shipping_country,
        p_phone,
        p_payment_method,
        CASE WHEN p_payment_method = 'cash_on_delivery' THEN 'pending' ELSE 'pending' END,
        NOW(),
        NOW()
    ) RETURNING id, order_number INTO v_order_id, v_order_number;
    
    -- Create order items from cart (with type casting for mixed schema)
    FOR cart_item IN (
        SELECT ci.*, p.name, p.sku, p.price, p.seller_id
        FROM public.cart_items ci
        JOIN public.carts c ON ci.cart_id = c.id
        JOIN public.products p ON ci.product_id::text = p.id::text
        WHERE c.user_id::text = p_user_id::text
    ) LOOP
        INSERT INTO public.order_items (
            order_id,
            product_id,
            product_name,
            product_sku,
            price,
            quantity,
            created_at
        ) VALUES (
            v_order_id,
            cart_item.product_id,
            cart_item.name,
            cart_item.sku,
            cart_item.price,
            cart_item.quantity,
            NOW()
        );
        
        -- Reduce product stock (with type casting for mixed schema)
        UPDATE public.products
        SET stock = stock - cart_item.quantity,
            updated_at = NOW()
        WHERE id::text = cart_item.product_id::text;
    END LOOP;
    
    -- Clear cart (with type casting for mixed schema)
    DELETE FROM public.cart_items
    WHERE cart_id IN (
        SELECT id FROM public.carts WHERE user_id::text = p_user_id::text
    );
    
    -- Return order info
    RETURN QUERY SELECT v_order_id, v_order_number, v_total;
END;
$$ LANGUAGE plpgsql;

-- Step 5: Create trigger for order creation notifications
-- ============================================================================

CREATE OR REPLACE FUNCTION notify_order_created() RETURNS TRIGGER AS $$
BEGIN
    -- Insert notification for seller (when Supabase Realtime is used)
    PERFORM pg_notify(
        'order_created',
        json_build_object(
            'order_id', NEW.id,
            'order_number', NEW.order_number,
            'total', NEW.total,
            'status', NEW.status
        )::text
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_order_created ON public.orders;

CREATE TRIGGER trigger_notify_order_created
    AFTER INSERT ON public.orders
    FOR EACH ROW
    EXECUTE FUNCTION notify_order_created();

-- Step 6: Create view for order summaries
-- ============================================================================

CREATE OR REPLACE VIEW public.order_summaries AS
SELECT 
    o.id,
    o.order_number,
    o.user_id,
    u.email AS customer_email,
    u.username AS customer_name,
    o.status,
    o.subtotal,
    o.tax,
    o.shipping_cost,
    o.total,
    o.payment_method,
    o.payment_status,
    o.shipping_address,
    o.shipping_city,
    o.shipping_state,
    o.shipping_zip,
    o.shipping_country,
    o.phone,
    COUNT(oi.id) AS items_count,
    o.created_at,
    o.updated_at
FROM public.orders o
LEFT JOIN public.users u ON o.user_id::text = u.id::text
LEFT JOIN public.order_items oi ON o.id = oi.order_id
GROUP BY o.id, u.email, u.username;

GRANT SELECT ON public.order_summaries TO authenticated;

-- Step 7: Update RLS policies for orders
-- ============================================================================

-- Allow users to insert their own orders
DROP POLICY IF EXISTS "Users can insert their own orders" ON public.orders;
CREATE POLICY "Users can insert their own orders"
ON public.orders FOR INSERT
TO authenticated
WITH CHECK (user_id::text = auth.uid()::text);

-- Allow users to view their own orders
DROP POLICY IF EXISTS "Users can view their own orders" ON public.orders;
CREATE POLICY "Users can view their own orders"
ON public.orders FOR SELECT
TO authenticated
USING (user_id::text = auth.uid()::text);

-- Step 8: Create indexes for checkout performance
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_orders_user_created 
ON public.orders(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_orders_status_created 
ON public.orders(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_orders_payment_method 
ON public.orders(payment_method);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id 
ON public.order_items(order_id);

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Test order total calculation
SELECT * FROM calculate_order_totals('00000000-0000-0000-0000-000000000000'::UUID);

-- Check payment method constraint
SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conrelid = 'public.orders'::regclass
AND conname = 'orders_payment_method_check';

-- Check functions exist
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name IN (
    'validate_checkout_order', 
    'calculate_order_totals', 
    'process_checkout',
    'notify_order_created'
);

-- Check indexes
SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'orders'
AND indexname LIKE 'idx_orders_%';

-- ============================================================================
-- COMPLETE!
-- Checkout process is now fully synced with database
-- Cash on Delivery payment method supported
-- Validation and calculation functions ready
-- ============================================================================

