-- =====================================================
-- Django Schema Sync for Supabase
-- Creates all tables matching Django models exactly
-- Run this in Supabase SQL Editor
-- =====================================================

-- OPTIONAL: Uncomment these to start fresh (WARNING: Deletes all data!)
-- DROP TABLE IF EXISTS django_migrations CASCADE;
-- DROP TABLE IF EXISTS django_admin_log CASCADE;
-- DROP TABLE IF EXISTS django_content_type CASCADE;
-- DROP TABLE IF EXISTS django_session CASCADE;
-- DROP TABLE IF EXISTS auth_permission CASCADE;
-- DROP TABLE IF EXISTS auth_group CASCADE;
-- DROP TABLE IF EXISTS auth_group_permissions CASCADE;
-- DROP TABLE IF EXISTS auth_user CASCADE;
-- DROP TABLE IF EXISTS auth_user_groups CASCADE;
-- DROP TABLE IF EXISTS auth_user_user_permissions CASCADE;
-- 
-- DROP TABLE IF EXISTS product_views CASCADE;
-- DROP TABLE IF EXISTS cart_activity_logs CASCADE;
-- DROP TABLE IF EXISTS search_queries CASCADE;
-- DROP TABLE IF EXISTS sales_metrics CASCADE;
-- DROP TABLE IF EXISTS seller_payouts CASCADE;
-- DROP TABLE IF EXISTS seller_profiles CASCADE;
-- DROP TABLE IF EXISTS order_status_history CASCADE;
-- DROP TABLE IF EXISTS order_items CASCADE;
-- DROP TABLE IF EXISTS orders CASCADE;
-- DROP TABLE IF EXISTS cart_items CASCADE;
-- DROP TABLE IF EXISTS carts CASCADE;
-- DROP TABLE IF EXISTS product_reviews CASCADE;
-- DROP TABLE IF EXISTS product_images CASCADE;
-- DROP TABLE IF EXISTS products CASCADE;
-- DROP TABLE IF EXISTS categories CASCADE;
-- DROP TABLE IF EXISTS users CASCADE;

-- =====================================================
-- USERS (Custom User Model)
-- =====================================================

CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    password VARCHAR(128) NOT NULL,
    last_login TIMESTAMP WITH TIME ZONE,
    is_superuser BOOLEAN NOT NULL DEFAULT FALSE,
    username VARCHAR(150) UNIQUE NOT NULL,
    first_name VARCHAR(150),
    last_name VARCHAR(150),
    email VARCHAR(254) UNIQUE NOT NULL,
    is_staff BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    date_joined TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    role VARCHAR(10) NOT NULL DEFAULT 'buyer' CHECK (role IN ('buyer', 'seller', 'admin')),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- =====================================================
-- CATEGORIES
-- =====================================================

CREATE TABLE IF NOT EXISTS categories (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    parent_id BIGINT REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_categories_slug ON categories(slug);
CREATE INDEX IF NOT EXISTS idx_categories_parent ON categories(parent_id);

-- =====================================================
-- PRODUCTS
-- =====================================================

CREATE TABLE IF NOT EXISTS products (
    id BIGSERIAL PRIMARY KEY,
    seller_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category_id BIGINT REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0),
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    sku VARCHAR(100) UNIQUE NOT NULL,
    brand VARCHAR(100),
    weight DECIMAL(6, 2),
    image_url VARCHAR(500),
    thumbnail_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_seller ON products(seller_id);
CREATE INDEX IF NOT EXISTS idx_products_category ON products(category_id);
CREATE INDEX IF NOT EXISTS idx_products_slug ON products(slug);
CREATE INDEX IF NOT EXISTS idx_products_sku ON products(sku);
CREATE INDEX IF NOT EXISTS idx_products_created ON products(created_at DESC);

-- =====================================================
-- PRODUCT IMAGES
-- =====================================================

CREATE TABLE IF NOT EXISTS product_images (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    image_url VARCHAR(500) NOT NULL,
    alt_text VARCHAR(255),
    "order" INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_product_images_product ON product_images(product_id);

-- =====================================================
-- PRODUCT REVIEWS
-- =====================================================

CREATE TABLE IF NOT EXISTS product_reviews (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(200) NOT NULL,
    comment TEXT NOT NULL,
    is_verified_purchase BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(product_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_product_reviews_product ON product_reviews(product_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_reviews_user ON product_reviews(user_id);

-- =====================================================
-- CARTS
-- =====================================================

CREATE TABLE IF NOT EXISTS carts (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_carts_user ON carts(user_id);

-- =====================================================
-- CART ITEMS
-- =====================================================

CREATE TABLE IF NOT EXISTS cart_items (
    id BIGSERIAL PRIMARY KEY,
    cart_id BIGINT NOT NULL REFERENCES carts(id) ON DELETE CASCADE,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    added_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(cart_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart ON cart_items(cart_id);
CREATE INDEX IF NOT EXISTS idx_cart_items_product ON cart_items(product_id);

-- =====================================================
-- ORDERS
-- =====================================================

CREATE TABLE IF NOT EXISTS orders (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled', 'refunded')),
    subtotal DECIMAL(10, 2) NOT NULL,
    tax DECIMAL(10, 2) NOT NULL DEFAULT 0,
    shipping_cost DECIMAL(10, 2) NOT NULL DEFAULT 0,
    total DECIMAL(10, 2) NOT NULL,
    shipping_address TEXT NOT NULL,
    shipping_city VARCHAR(100) NOT NULL,
    shipping_state VARCHAR(100) NOT NULL,
    shipping_zip VARCHAR(20) NOT NULL,
    shipping_country VARCHAR(100) NOT NULL DEFAULT 'US',
    phone VARCHAR(20) NOT NULL,
    payment_method VARCHAR(50) DEFAULT 'card',
    payment_status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    shipped_at TIMESTAMP WITH TIME ZONE,
    delivered_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_orders_user ON orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_number ON orders(order_number);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created ON orders(created_at DESC);

-- =====================================================
-- ORDER ITEMS
-- =====================================================

CREATE TABLE IF NOT EXISTS order_items (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
    product_name VARCHAR(255) NOT NULL,
    product_sku VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_items_order ON order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product ON order_items(product_id);

-- =====================================================
-- ORDER STATUS HISTORY
-- =====================================================

CREATE TABLE IF NOT EXISTS order_status_history (
    id BIGSERIAL PRIMARY KEY,
    order_id BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    status VARCHAR(20) NOT NULL,
    notes TEXT,
    changed_by_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order ON order_status_history(order_id, created_at DESC);

-- =====================================================
-- SELLER PROFILES
-- =====================================================

CREATE TABLE IF NOT EXISTS seller_profiles (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    business_name VARCHAR(200) NOT NULL,
    business_description TEXT,
    business_email VARCHAR(254) NOT NULL,
    business_phone VARCHAR(20) NOT NULL,
    business_address TEXT NOT NULL,
    business_city VARCHAR(100) NOT NULL,
    business_state VARCHAR(100) NOT NULL,
    business_zip VARCHAR(20) NOT NULL,
    business_country VARCHAR(100) NOT NULL DEFAULT 'US',
    tax_id VARCHAR(50),
    business_license VARCHAR(100),
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    average_rating DECIMAL(3, 2) DEFAULT 0.0,
    total_reviews INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    verified_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_seller_profiles_user ON seller_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_seller_profiles_verified ON seller_profiles(is_verified, is_active);

-- =====================================================
-- SELLER PAYOUTS
-- =====================================================

CREATE TABLE IF NOT EXISTS seller_payouts (
    id BIGSERIAL PRIMARY KEY,
    seller_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    transaction_id VARCHAR(200),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_seller_payouts_seller ON seller_payouts(seller_id, created_at DESC);

-- =====================================================
-- ANALYTICS - PRODUCT VIEWS
-- =====================================================

CREATE TABLE IF NOT EXISTS product_views (
    id BIGSERIAL PRIMARY KEY,
    product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    session_id VARCHAR(100) NOT NULL,
    ip_address INET,
    user_agent TEXT,
    referrer VARCHAR(500),
    viewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_product_views_product ON product_views(product_id, viewed_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_views_session ON product_views(session_id);

-- =====================================================
-- ANALYTICS - SEARCH QUERIES
-- =====================================================

CREATE TABLE IF NOT EXISTS search_queries (
    id BIGSERIAL PRIMARY KEY,
    query VARCHAR(255) NOT NULL,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    results_count INTEGER DEFAULT 0,
    session_id VARCHAR(100) NOT NULL,
    ip_address INET,
    searched_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_search_queries_searched ON search_queries(searched_at DESC);
CREATE INDEX IF NOT EXISTS idx_search_queries_query ON search_queries(query);

-- =====================================================
-- ANALYTICS - CART ACTIVITY LOGS
-- =====================================================

CREATE TABLE IF NOT EXISTS cart_activity_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
    action VARCHAR(20) NOT NULL CHECK (action IN ('add', 'remove', 'update', 'clear', 'checkout')),
    quantity INTEGER DEFAULT 0,
    session_id VARCHAR(100) NOT NULL,
    cart_total DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_cart_activity_logs_created ON cart_activity_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_cart_activity_logs_user ON cart_activity_logs(user_id, created_at DESC);

-- =====================================================
-- ANALYTICS - SALES METRICS
-- =====================================================

CREATE TABLE IF NOT EXISTS sales_metrics (
    id BIGSERIAL PRIMARY KEY,
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
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sales_metrics_date ON sales_metrics(date DESC);

-- =====================================================
-- GRANT PERMISSIONS
-- =====================================================

-- Grant access to anon and authenticated roles
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;

-- Allow anonymous inserts for analytics
GRANT INSERT ON product_views TO anon;
GRANT INSERT ON cart_activity_logs TO anon;
GRANT INSERT ON search_queries TO anon;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Django schema synced to Supabase successfully!';
    RAISE NOTICE '📊 All tables created with correct structure';
    RAISE NOTICE '🔑 Indexes optimized';
    RAISE NOTICE '🎯 Ready for Django connection';
END $$;

