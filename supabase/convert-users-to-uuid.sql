-- ============================================================================
-- Convert users table from BIGINT to UUID
-- This aligns the Supabase schema with Django's UUID-based User model
-- RUN THIS IN SUPABASE SQL EDITOR BEFORE DATA MIGRATION
-- ============================================================================

-- Step 1: Drop dependent objects (we'll recreate them)
DROP VIEW IF EXISTS public.product_listings CASCADE;
DROP VIEW IF EXISTS public.seller_stats CASCADE;
DROP VIEW IF EXISTS public.product_stats CASCADE;

-- Step 2: Drop foreign key constraints on dependent tables
ALTER TABLE IF EXISTS products DROP CONSTRAINT IF EXISTS products_seller_id_fkey;
ALTER TABLE IF EXISTS orders DROP CONSTRAINT IF EXISTS orders_user_id_fkey;
ALTER TABLE IF EXISTS carts DROP CONSTRAINT IF EXISTS carts_user_id_fkey;
ALTER TABLE IF EXISTS seller_profiles DROP CONSTRAINT IF EXISTS seller_profiles_user_id_fkey;
ALTER TABLE IF EXISTS seller_payouts DROP CONSTRAINT IF EXISTS seller_payouts_seller_id_fkey;
ALTER TABLE IF EXISTS product_views DROP CONSTRAINT IF EXISTS product_views_user_id_fkey;
ALTER TABLE IF EXISTS search_queries DROP CONSTRAINT IF EXISTS search_queries_user_id_fkey;
ALTER TABLE IF EXISTS cart_activity_logs DROP CONSTRAINT IF EXISTS cart_activity_logs_user_id_fkey;
ALTER TABLE IF EXISTS product_reviews DROP CONSTRAINT IF EXISTS product_reviews_user_id_fkey;
ALTER TABLE IF EXISTS order_status_history DROP CONSTRAINT IF EXISTS order_status_history_changed_by_id_fkey;

-- Step 3: Delete all existing user data (since we're migrating fresh from SQLite)
TRUNCATE TABLE users CASCADE;

-- Step 4: Alter the users table ID column to UUID
ALTER TABLE users 
    ALTER COLUMN id TYPE UUID USING uuid_generate_v4(),
    ALTER COLUMN id SET DEFAULT uuid_generate_v4();

-- Step 5: Alter dependent table columns to UUID
ALTER TABLE products ALTER COLUMN seller_id TYPE UUID USING NULL;
ALTER TABLE orders ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE carts ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE seller_profiles ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE seller_payouts ALTER COLUMN seller_id TYPE UUID USING NULL;
ALTER TABLE product_views ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE search_queries ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE cart_activity_logs ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE product_reviews ALTER COLUMN user_id TYPE UUID USING NULL;
ALTER TABLE order_status_history ALTER COLUMN changed_by_id TYPE UUID USING NULL;

-- Step 6: Recreate foreign key constraints
ALTER TABLE products 
    ADD CONSTRAINT products_seller_id_fkey 
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE orders 
    ADD CONSTRAINT orders_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE carts 
    ADD CONSTRAINT carts_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE seller_profiles 
    ADD CONSTRAINT seller_profiles_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE seller_payouts 
    ADD CONSTRAINT seller_payouts_seller_id_fkey 
    FOREIGN KEY (seller_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE product_views 
    ADD CONSTRAINT product_views_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE search_queries 
    ADD CONSTRAINT search_queries_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE cart_activity_logs 
    ADD CONSTRAINT cart_activity_logs_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL;

ALTER TABLE product_reviews 
    ADD CONSTRAINT product_reviews_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE order_status_history 
    ADD CONSTRAINT order_status_history_changed_by_id_fkey 
    FOREIGN KEY (changed_by_id) REFERENCES users(id) ON DELETE SET NULL;

-- Step 7: Alter other tables to use UUID for their IDs as well
ALTER TABLE categories ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE categories ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE categories ALTER COLUMN parent_id TYPE UUID USING NULL;

ALTER TABLE products ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE products ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE products ALTER COLUMN category_id TYPE UUID USING NULL;

ALTER TABLE orders ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE orders ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE order_items ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE order_items ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE order_items ALTER COLUMN order_id TYPE UUID USING NULL;
ALTER TABLE order_items ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE carts ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE carts ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE cart_items ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE cart_items ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE cart_items ALTER COLUMN cart_id TYPE UUID USING NULL;
ALTER TABLE cart_items ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE seller_profiles ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE seller_profiles ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE seller_payouts ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE seller_payouts ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE product_images ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE product_images ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE product_images ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE product_reviews ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE product_reviews ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE product_reviews ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE product_views ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE product_views ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE product_views ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE search_queries ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE search_queries ALTER COLUMN id SET DEFAULT uuid_generate_v4();

ALTER TABLE cart_activity_logs ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE cart_activity_logs ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE cart_activity_logs ALTER COLUMN product_id TYPE UUID USING NULL;

ALTER TABLE order_status_history ALTER COLUMN id TYPE UUID USING uuid_generate_v4();
ALTER TABLE order_status_history ALTER COLUMN id SET DEFAULT uuid_generate_v4();
ALTER TABLE order_status_history ALTER COLUMN order_id TYPE UUID USING NULL;

-- Step 8: Recreate remaining foreign keys
ALTER TABLE categories 
    ADD CONSTRAINT categories_parent_id_fkey 
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE CASCADE;

ALTER TABLE products 
    ADD CONSTRAINT products_category_id_fkey 
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL;

ALTER TABLE order_items 
    ADD CONSTRAINT order_items_order_id_fkey 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

ALTER TABLE order_items 
    ADD CONSTRAINT order_items_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE cart_items 
    ADD CONSTRAINT cart_items_cart_id_fkey 
    FOREIGN KEY (cart_id) REFERENCES carts(id) ON DELETE CASCADE;

ALTER TABLE cart_items 
    ADD CONSTRAINT cart_items_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE product_images 
    ADD CONSTRAINT product_images_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE product_reviews 
    ADD CONSTRAINT product_reviews_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE product_views 
    ADD CONSTRAINT product_views_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE;

ALTER TABLE cart_activity_logs 
    ADD CONSTRAINT cart_activity_logs_product_id_fkey 
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL;

ALTER TABLE order_status_history 
    ADD CONSTRAINT order_status_history_order_id_fkey 
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE;

-- Step 9: Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Successfully converted all tables to use UUID!';
    RAISE NOTICE '📊 All foreign key constraints recreated';
    RAISE NOTICE '🎯 Ready for Django UUID-based data migration';
END $$;

