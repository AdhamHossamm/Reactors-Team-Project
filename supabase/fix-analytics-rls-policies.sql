-- =====================================================
-- Fix Analytics Tables RLS Policies
-- Add missing RLS policies for product_views and cart_activity_logs
-- =====================================================

-- Enable RLS on analytics tables (if not already enabled)
ALTER TABLE public.product_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_activity_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.search_queries ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Anyone can insert product views" ON public.product_views;
DROP POLICY IF EXISTS "Anyone can view product views" ON public.product_views;
DROP POLICY IF EXISTS "Authenticated users can view product views" ON public.product_views;
DROP POLICY IF EXISTS "Anyone can insert cart activity logs" ON public.cart_activity_logs;
DROP POLICY IF EXISTS "Authenticated users can view cart activity logs" ON public.cart_activity_logs;
DROP POLICY IF EXISTS "Anyone can insert search queries" ON public.search_queries;
DROP POLICY IF EXISTS "Authenticated users can view search queries" ON public.search_queries;

-- Product Views Policies
-- Allow anonymous users to insert product views for analytics
CREATE POLICY "Anyone can insert product views" ON public.product_views
    FOR INSERT WITH CHECK (true);

-- Allow read access for analytics purposes (authenticated users only)
CREATE POLICY "Authenticated users can view product views" ON public.product_views
    FOR SELECT USING (auth.role() = 'authenticated');

-- Cart Activity Logs Policies
-- Allow anonymous users to insert cart activity logs for analytics
CREATE POLICY "Anyone can insert cart activity logs" ON public.cart_activity_logs
    FOR INSERT WITH CHECK (true);

-- Allow read access for analytics purposes (authenticated users only)
CREATE POLICY "Authenticated users can view cart activity logs" ON public.cart_activity_logs
    FOR SELECT USING (auth.role() = 'authenticated');

-- Search Queries Policies
-- Allow anonymous users to insert search queries for analytics
CREATE POLICY "Anyone can insert search queries" ON public.search_queries
    FOR INSERT WITH CHECK (true);

-- Allow read access for analytics purposes (authenticated users only)
CREATE POLICY "Authenticated users can view search queries" ON public.search_queries
    FOR SELECT USING (auth.role() = 'authenticated');

-- Grant necessary permissions for anon role
GRANT INSERT ON public.product_views TO anon;
GRANT INSERT ON public.cart_activity_logs TO anon;
GRANT INSERT ON public.search_queries TO anon;

-- Grant necessary permissions for authenticated role
GRANT SELECT ON public.product_views TO authenticated;
GRANT SELECT ON public.cart_activity_logs TO authenticated;
GRANT SELECT ON public.search_queries TO authenticated;

-- Success message
DO $$
BEGIN
    RAISE NOTICE '✅ Analytics RLS policies updated successfully!';
    RAISE NOTICE '📊 Tables: product_views, cart_activity_logs, search_queries';
    RAISE NOTICE '🔒 RLS: Enabled with anonymous INSERT and authenticated SELECT';
END $$;

