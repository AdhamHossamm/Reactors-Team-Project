# Supabase Storage Setup Instructions

## Problem
Product image uploads are failing with error: **"new row violates row-level security policy"**

## Solution
Run the SQL script to create the storage bucket and configure RLS policies.

## Steps to Fix

### 1. Open Supabase SQL Editor
1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: **mbwyjrfnbjeseslcveyb**
3. Click on **SQL Editor** in the left sidebar
4. Click **"New query"**

### 2. Run the Setup Script
1. Open the file: `supabase/setup-storage-rls.sql`
2. Copy **ALL** the SQL code
3. Paste it into the Supabase SQL Editor
4. Click **"Run"** button (or press Ctrl+Enter)

### 3. Verify Success
You should see a success message. The script will:
- ✅ Create `product-images` storage bucket (if doesn't exist)
- ✅ Enable Row Level Security (RLS)
- ✅ Create policies allowing image uploads via anon key
- ✅ Allow public read access for product images
- ✅ Grant necessary permissions

### 4. Verify Storage Bucket
1. Go to **Storage** in the Supabase sidebar
2. You should see the `product-images` bucket
3. Check that it's marked as **Public**
4. Verify folder structure will be: `product-images/products/`

## Architecture Note
- **Django** handles user authentication (JWT tokens)
- **Supabase** provides storage only (using anon key)
- **RLS policies** allow anon role to upload to `products/` folder
- **Security** is maintained through Django API access control

## Testing
After running the SQL:
1. Try adding a product with an image
2. Upload should succeed
3. Image should be publicly accessible via URL

## Troubleshooting

### If upload still fails:
1. Check bucket exists: Go to Storage > product-images
2. Verify RLS policies: SQL Editor > Run:
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'objects' 
   AND schemaname = 'storage';
   ```
3. Check you're using the correct anon key in `frontend/.env.local`

### If bucket already exists with different settings:
The SQL script uses `ON CONFLICT DO UPDATE` so it's safe to run multiple times.

## Security Considerations
- ✅ Public read access (needed for displaying images)
- ✅ Anon role can upload (controlled by Django auth in frontend)
- ✅ File size limit: 5MB
- ✅ Allowed types: JPEG, PNG, WebP, GIF
- ✅ Files organized in `products/` folder
- ❌ No direct database access from frontend (Django API only)

