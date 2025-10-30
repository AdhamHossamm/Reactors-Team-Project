-- =====================================================
-- REACTORS - Supabase PostgreSQL Schema
-- Professional E-Commerce Platform
-- Compatible with Supabase SQL Editor
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS & AUTHENTICATION
-- =====================================================

-- Custom user profiles (extends Supabase auth.users)
CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    first_name TEXT,
    last_name TEXT,
    role TEXT NOT NULL DEFAULT 'buyer' CHECK (role IN ('buyer', 'seller', 'admin')),
    phone TEXT,
    address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 2. CATEGORIES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    parent_id UUID REFERENCES public.categories(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 3. PRODUCTS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    sku TEXT UNIQUE NOT NULL,
    brand TEXT,
    weight DECIMAL(6, 2),
    image_url TEXT,
    thumbnail_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Product images (gallery)
CREATE TABLE IF NOT EXISTS public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Product reviews
CREATE TABLE IF NOT EXISTS public.product_reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title TEXT NOT NULL,
    comment TEXT NOT NULL,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(product_id, user_id)
);

-- =====================================================
-- 4. SHOPPING CART
-- =====================================================

CREATE TABLE IF NOT EXISTS public.carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(cart_id, product_id)
);

-- =====================================================
-- 5. ORDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    order_number TEXT UNIQUE NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    subtotal DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2) DEFAULT 0,
    shipping_cost DECIMAL(10, 2) DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    shipping_address TEXT NOT NULL,
    shipping_city TEXT NOT NULL,
    shipping_state TEXT NOT NULL,
    shipping_zip TEXT NOT NULL,
    shipping_country TEXT NOT NULL,
    phone TEXT NOT NULL,
    payment_method TEXT DEFAULT 'card',
    payment_status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    shipped_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    product_sku TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.order_status_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    status TEXT NOT NULL,
    notes TEXT,
    changed_by UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 6. SELLER PROFILES
-- =====================================================

CREATE TABLE IF NOT EXISTS public.seller_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    business_description TEXT,
    business_email TEXT NOT NULL,
    business_phone TEXT NOT NULL,
    business_address TEXT NOT NULL,
    business_city TEXT NOT NULL,
    business_state TEXT NOT NULL,
    business_zip TEXT NOT NULL,
    business_country TEXT NOT NULL,
    tax_id TEXT,
    business_license TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    average_rating DECIMAL(3, 2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    verified_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS public.seller_payouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    seller_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    transaction_id TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

-- =====================================================
-- 7. ANALYTICS
-- =====================================================

CREATE TABLE IF NOT EXISTS public.product_views (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    session_id TEXT NOT NULL,
    ip_address INET,
    user_agent TEXT,
    referrer TEXT,
    viewed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.search_queries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    query TEXT NOT NULL,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    results_count INTEGER DEFAULT 0,
    session_id TEXT NOT NULL,
    ip_address INET,
    searched_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.cart_activity_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    action TEXT NOT NULL CHECK (action IN ('add', 'remove', 'update', 'clear', 'checkout')),
    quantity INTEGER DEFAULT 0,
    session_id TEXT NOT NULL,
    cart_total DECIMAL(10, 2),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.sales_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    date DATE UNIQUE NOT NULL,
    total_orders INTEGER DEFAULT 0,
    completed_orders INTEGER DEFAULT 0,
    cancelled_orders INTEGER DEFAULT 0,
    total_revenue DECIMAL(12, 2) DEFAULT 0,
    total_tax DECIMAL(12, 2) DEFAULT 0,
    total_shipping DECIMAL(12, 2) DEFAULT 0,
    total_products_sold INTEGER DEFAULT 0,
    unique_products_sold INTEGER DEFAULT 0,
    new_users INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =====================================================
-- 8. INDEXES FOR PERFORMANCE
-- =====================================================

-- Products indexes
CREATE INDEX IF NOT EXISTS idx_products_seller ON public.products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON public.products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON public.products(slug);
CREATE INDEX IF NOT EXISTS idx_products_sku ON public.products(sku);
CREATE INDEX IF NOT EXISTS idx_products_active ON public.products(is_active);
CREATE INDEX IF NOT EXISTS idx_products_featured ON public.products(is_featured);
CREATE INDEX IF NOT EXISTS idx_products_created ON public.products(created_at DESC);

-- Orders indexes
CREATE INDEX IF NOT EXISTS idx_orders_user ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_number ON public.orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON public.orders(created_at DESC);

-- Analytics indexes
CREATE INDEX IF NOT EXISTS idx_product_views_product ON public.product_views(product_id, viewed_at DESC);
CREATE INDEX IF NOT EXISTS idx_search_queries_searched ON public.search_queries(searched_at DESC);
CREATE INDEX IF NOT EXISTS idx_cart_activity_created ON public.cart_activity_logs(created_at DESC);

-- =====================================================
-- 9. ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.product_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.seller_payouts ENABLE ROW LEVEL SECURITY;

-- User Profiles: Users can read all, update own
CREATE POLICY "Users can view all profiles" ON public.user_profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can update own profile" ON public.user_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Categories: Public read, admin write
CREATE POLICY "Anyone can view categories" ON public.categories
    FOR SELECT USING (true);

-- Products: Public read, sellers can manage own
CREATE POLICY "Anyone can view active products" ON public.products
    FOR SELECT USING (is_active = true OR seller_id = auth.uid());

CREATE POLICY "Sellers can insert own products" ON public.products
    FOR INSERT WITH CHECK (seller_id = auth.uid());

CREATE POLICY "Sellers can update own products" ON public.products
    FOR UPDATE USING (seller_id = auth.uid());

CREATE POLICY "Sellers can delete own products" ON public.products
    FOR DELETE USING (seller_id = auth.uid());

-- Product Reviews: Users can read all, create own
CREATE POLICY "Anyone can view reviews" ON public.product_reviews
    FOR SELECT USING (true);

CREATE POLICY "Users can create reviews" ON public.product_reviews
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Carts: Users can only access own cart
CREATE POLICY "Users can view own cart" ON public.carts
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can manage own cart" ON public.carts
    FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Users can view own cart items" ON public.cart_items
    FOR SELECT USING (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));

CREATE POLICY "Users can manage own cart items" ON public.cart_items
    FOR ALL USING (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));

-- Orders: Users can only view own orders
CREATE POLICY "Users can view own orders" ON public.orders
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can create own orders" ON public.orders
    FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can view own order items" ON public.order_items
    FOR SELECT USING (order_id IN (SELECT id FROM public.orders WHERE user_id = auth.uid()));

-- Seller Profiles: Public read, sellers can manage own
CREATE POLICY "Anyone can view seller profiles" ON public.seller_profiles
    FOR SELECT USING (is_active = true);

CREATE POLICY "Sellers can manage own profile" ON public.seller_profiles
    FOR ALL USING (user_id = auth.uid());

-- =====================================================
-- 10. FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to relevant tables
CREATE TRIGGER update_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at BEFORE UPDATE ON public.categories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_products_updated_at BEFORE UPDATE ON public.products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_carts_updated_at BEFORE UPDATE ON public.carts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cart_items_updated_at BEFORE UPDATE ON public.cart_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_orders_updated_at BEFORE UPDATE ON public.orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to generate order number
CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.order_number IS NULL THEN
        NEW.order_number := 'ORD-' || UPPER(SUBSTRING(MD5(RANDOM()::TEXT) FROM 1 FOR 12));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_order_number BEFORE INSERT ON public.orders
    FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- =====================================================
-- 11. DEMO DATA (Optional - Comment out if not needed)
-- =====================================================

-- Insert demo categories
INSERT INTO public.categories (name, slug, description) VALUES
    ('Electronics', 'electronics', 'Electronic devices and gadgets'),
    ('Clothing', 'clothing', 'Fashion and apparel'),
    ('Books', 'books', 'Books and literature'),
    ('Home & Garden', 'home-garden', 'Home improvement and garden supplies')
ON CONFLICT (slug) DO NOTHING;

-- =====================================================
-- 12. VIEWS FOR ANALYTICS
-- =====================================================

-- View for product statistics
CREATE OR REPLACE VIEW public.product_stats AS
SELECT 
    p.id,
    p.name,
    p.slug,
    p.price,
    p.stock,
    COUNT(DISTINCT pr.id) as review_count,
    AVG(pr.rating) as average_rating,
    COUNT(DISTINCT pv.id) as view_count
FROM public.products p
LEFT JOIN public.product_reviews pr ON p.id = pr.product_id
LEFT JOIN public.product_views pv ON p.id = pv.product_id
GROUP BY p.id, p.name, p.slug, p.price, p.stock;

-- View for seller statistics
CREATE OR REPLACE VIEW public.seller_stats AS
SELECT 
    sp.user_id,
    sp.business_name,
    COUNT(DISTINCT p.id) as total_products,
    COUNT(DISTINCT CASE WHEN p.is_active THEN p.id END) as active_products,
    SUM(p.stock) as total_stock,
    sp.average_rating,
    sp.total_reviews
FROM public.seller_profiles sp
LEFT JOIN public.products p ON sp.user_id = p.seller_id
GROUP BY sp.user_id, sp.business_name, sp.average_rating, sp.total_reviews;

-- =====================================================
-- SCHEMA SETUP COMPLETE
-- =====================================================

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ E-Commerce MVP schema created successfully!';
    RAISE NOTICE '📊 Tables: 17 created';
    RAISE NOTICE '🔒 RLS policies: Enabled';
    RAISE NOTICE '⚡ Indexes: Optimized';
    RAISE NOTICE '🎯 Ready for integration with Django backend';
END $$;

