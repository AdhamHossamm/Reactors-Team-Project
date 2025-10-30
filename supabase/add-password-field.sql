-- Add password and last_login fields to user_profiles table
-- These are needed for Django's AbstractBaseUser compatibility

ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS password VARCHAR(128) DEFAULT '',
ADD COLUMN IF NOT EXISTS last_login TIMESTAMP WITH TIME ZONE NULL;

-- Update existing records to have a placeholder password
UPDATE user_profiles SET password = '' WHERE password IS NULL OR password = '';

-- Verify the changes
SELECT 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_name = 'user_profiles' 
  AND column_name IN ('password', 'last_login')
ORDER BY column_name;

SELECT '✅ Password and last_login fields added to user_profiles' AS status;

