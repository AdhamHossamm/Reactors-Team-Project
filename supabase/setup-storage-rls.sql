-- =====================================================
-- Supabase Storage Setup for Product Images
-- =====================================================
-- This script sets up the storage bucket and RLS policies
-- for product image uploads
-- =====================================================

-- 1. Create storage bucket for product images (if not exists)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images',
  'product-images',
  true,  -- Public bucket for read access
  5242880,  -- 5MB file size limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = true,
  file_size_limit = 5242880,
  allowed_mime_types = ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/gif'];

-- 2. Enable RLS on storage.objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies if they exist (for idempotency)
DROP POLICY IF EXISTS "Public read access for product images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload product images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update own images" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete own images" ON storage.objects;
DROP POLICY IF EXISTS "Anon role can upload product images" ON storage.objects;
DROP POLICY IF EXISTS "Anon role can update product images" ON storage.objects;
DROP POLICY IF EXISTS "Anon role can delete product images" ON storage.objects;
DROP POLICY IF EXISTS "Service role has full access" ON storage.objects;

-- 4. Policy: Public can view/download product images
CREATE POLICY "Public read access for product images"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'product-images');

-- 5. Policy: Allow anon role to upload images (since we use Django JWT, not Supabase auth)
-- Note: The anon key is used by the frontend, and Django handles authentication
CREATE POLICY "Anon role can upload product images"
ON storage.objects
FOR INSERT
TO anon, authenticated
WITH CHECK (
  bucket_id = 'product-images' 
  AND (storage.foldername(name))[1] = 'products'
);

-- 6. Policy: Allow anon role to update images
CREATE POLICY "Anon role can update product images"
ON storage.objects
FOR UPDATE
TO anon, authenticated
USING (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = 'products'
)
WITH CHECK (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = 'products'
);

-- 7. Policy: Allow anon role to delete images
CREATE POLICY "Anon role can delete product images"
ON storage.objects
FOR DELETE
TO anon, authenticated
USING (
  bucket_id = 'product-images'
  AND (storage.foldername(name))[1] = 'products'
);

-- 8. Policy: Service role has full access (for backend operations)
CREATE POLICY "Service role has full access"
ON storage.objects
FOR ALL
TO service_role
USING (bucket_id = 'product-images')
WITH CHECK (bucket_id = 'product-images');

-- 9. Grant necessary permissions
GRANT ALL ON storage.objects TO anon, authenticated;
GRANT ALL ON storage.buckets TO anon, authenticated;

-- =====================================================
-- Verification Queries
-- =====================================================
-- Run these to verify the setup:

-- Check bucket configuration:
-- SELECT * FROM storage.buckets WHERE id = 'product-images';

-- Check RLS policies:
-- SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';

-- Test upload permission (should return true for authenticated users):
-- SELECT storage.objects.bucket_id, storage.objects.name
-- FROM storage.objects
-- WHERE bucket_id = 'product-images';

