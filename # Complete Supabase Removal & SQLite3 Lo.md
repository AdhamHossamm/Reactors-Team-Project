# Complete Supabase Removal & SQLite3 Local Setup

## Backend Changes

### 1. Remove Supabase Dependencies

- Remove `supabase==2.10.0` from `requirements.txt`
- Remove `psycopg2-binary==2.9.10` (PostgreSQL adapter)
- Clean up Supabase configuration from `settings.py`
- Delete Supabase-specific files: `supabase_sync.py`, `jwt_auth.py`, `signals.py`
- Remove Supabase signal connections from `users/apps.py`

### 2. Update User Model & Authentication

- Simplify User model to remove Supabase UUID references
- Keep Django REST Framework JWT authentication
- Remove Supabase sync logic from user operations
- Ensure standard Django admin compatibility

### 3. Database Setup

- Ensure SQLite3 is properly configured in settings
- Create fresh migrations if needed
- Create dummy accounts:
- Admin: admin@example.com / admin
- Superuser: superuser@example.com / superuser
- Sample seller and buyer accounts

## Frontend Changes

### 4. Remove Supabase Client Integration

- Remove `@supabase/supabase-js` dependency from `package.json`
- Delete `services/supabase.js` completely
- Remove Supabase imports from `useAuthStore.js`
- Delete Supabase test page
- Update authentication to use only Django JWT

### 5. Clean Frontend Auth Flow

- Remove all Supabase auth synchronization
- Simplify auth store to work with Django JWT only
- Remove Supabase-specific error handling
- Update API calls to work with local backend only

## Server & Admin Setup

### 6. Django Server Configuration

- Ensure Django development server runs on localhost:8000
- Verify admin interface accessibility
- Test CORS configuration for frontend integration
- Create management commands for easy setup

### 7. Integration Testing

- Verify Django admin works at http://localhost:8000/admin/
- Test frontend authentication flow
- Confirm all CRUD operations work locally
- Validate seller/buyer role functionality
