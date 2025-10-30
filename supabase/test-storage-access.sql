-- =====================================================
-- Test Storage Access and RLS Policies
-- =====================================================
-- Run this after setup-storage-rls.sql to verify everything works
-- =====================================================

-- 1. Check if bucket exists
SELECT 
  id, 
  name, 
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'product-images';
-- Expected: 1 row showing the bucket with public=true

-- 2. Check RLS is enabled
SELECT 
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'storage' 
AND tablename = 'objects';
-- Expected: rowsecurity = true

-- 3. List all RLS policies for storage.objects
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
ORDER BY policyname;
-- Expected: 5 policies (Public read, Anon upload/update/delete, Service role full)

-- 4. Check specific policy for uploads
SELECT 
  policyname,
  roles,
  cmd as operation
FROM pg_policies 
WHERE schemaname = 'storage' 
AND tablename = 'objects'
AND cmd = 'INSERT';
-- Expected: Shows "Anon role can upload product images" and "Service role has full access"

-- 5. Test permissions (this won't insert, just checks policy)
EXPLAIN (COSTS OFF)
SELECT * FROM storage.objects
WHERE bucket_id = 'product-images'
AND (storage.foldername(name))[1] = 'products';
-- Expected: Query plan showing RLS policies are active

-- =====================================================
-- Success Indicators
-- =====================================================
-- ✅ Bucket 'product-images' exists and is public
-- ✅ RLS is enabled on storage.objects
-- ✅ 5 policies are created (1 public read, 3 anon, 1 service_role)
-- ✅ Anon role can INSERT/UPDATE/DELETE in products/ folder
-- =====================================================

