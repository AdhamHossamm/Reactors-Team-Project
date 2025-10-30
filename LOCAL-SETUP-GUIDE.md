# Local Development Setup Guide

Complete guide for running the E-Commerce platform locally with SQLite3.

## Prerequisites

- Python 3.11+
- Node.js 18+
- pip (Python package manager)
- npm or yarn (Node package manager)
- SQLite3 (included with Python)

## Backend Setup

### 1. Navigate to Backend Directory

```bash
cd backend
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Run Database Migrations

```bash
python manage.py makemigrations
python manage.py migrate
```

This creates the SQLite database file at `backend/db.sqlite3`.

### 4. Create Test Accounts

```bash
python manage.py setup_local
```

This creates the following test accounts:

- **Admin**: admin@example.com / admin
- **Superuser**: superuser@example.com / superuser
- **Seller**: seller@example.com / seller123
- **Buyer**: buyer@example.com / buyer123

### 5. Start Django Development Server

```bash
python manage.py runserver
```

Backend will be available at: **http://localhost:8000**

- API Documentation: http://localhost:8000/api/schema/swagger-ui/
- Admin Panel: http://localhost:8000/admin/
  - Login with: admin@example.com / admin

## Frontend Setup

### 1. Navigate to Frontend Directory

```bash
cd frontend
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Create Environment File

Create `.env.local` in the `frontend/` directory:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

### 4. Start Next.js Development Server

```bash
npm run dev
```

Frontend will be available at: **http://localhost:3000**

## Test Accounts

Use these accounts to test different user roles:

### Admin Account
- **Email**: admin@example.com
- **Password**: admin
- **Access**: Full admin panel access, all CRUD operations

### Superuser Account
- **Email**: superuser@example.com
- **Password**: superuser
- **Access**: Admin panel access with superuser privileges

### Seller Account
- **Email**: seller@example.com
- **Password**: seller123
- **Access**: Seller dashboard, product management

### Buyer Account
- **Email**: buyer@example.com
- **Password**: buyer123
- **Access**: Product browsing, cart, checkout

## Verifying Setup

### 1. Check Backend

1. Visit http://localhost:8000/admin/
2. Login with admin@example.com / admin
3. Verify you can access the admin panel
4. Check that `backend/db.sqlite3` file exists
5. Verify database file exists: `backend/db.sqlite3`

### 2. Check Frontend

1. Visit http://localhost:3000
2. Check browser console for any errors
3. Try logging in with buyer@example.com / buyer123
4. Browse the products page

### 3. End-to-End Testing

Test these workflows:

- [ ] User Registration
- [ ] User Login/Logout
- [ ] Browse Products
- [ ] Add Products to Cart
- [ ] View Cart
- [ ] Complete Checkout Process
- [ ] View Orders
- [ ] Seller Dashboard Access
- [ ] Seller Product Creation
- [ ] Image Upload (to Django media folder)

## Media Files

Product images are stored locally in the Django backend:

- **Location**: `backend/media/products/`
- **Access**: Served automatically at http://localhost:8000/media/
- **Configuration**: Already set up in Django settings

## Troubleshooting

### Backend Issues

**Database not found:**
```bash
cd backend
python manage.py migrate
```

**Authentication errors:**
```bash
python manage.py createsuperuser
# Or use the setup_local command
python manage.py setup_local
```

**Port already in use:**
Change the port:
```bash
python manage.py runserver 8001
```

### Frontend Issues

**API connection errors:**
- Verify `NEXT_PUBLIC_API_URL` in `.env.local`
- Check backend server is running
- Check CORS settings in Django

**Module not found errors:**
```bash
cd frontend
npm install
```

**Port already in use:**
```bash
npm run dev -- -p 3001
```

## Project Structure

```
RP---e-Commerce-FS/
├── backend/                    # Django backend
│   ├── db.sqlite3             # SQLite database
│   ├── media/                  # User uploaded files
│   │   └── products/          # Product images
│   └── manage.py              # Django management script
├── frontend/                   # Next.js frontend
│   ├── .env.local             # Environment variables
│   └── pages/                 # Next.js pages
└── LOCAL-SETUP-GUIDE.md        # This file
```

## Additional Commands

### Backend Management

```bash
# Create migrations
cd backend
python manage.py makemigrations

# Apply migrations
python manage.py migrate

# Create superuser
python manage.py createsuperuser

# Setup test accounts
python manage.py setup_local

# Access Django shell
python manage.py shell

# Run tests
python manage.py test
```

### Frontend Development

```bash
# Start dev server
cd frontend
npm run dev

# Build for production
npm run build

# Start production server
npm run start

# Run linter
npm run lint
```

## Environment Variables

### Backend (.env)

Create `backend/.env` (optional for local development):

```env
SECRET_KEY=django-insecure-local-dev-key-change-in-production
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
CORS_ALLOWED_ORIGINS=http://localhost:3000,http://127.0.0.1:3000
```

### Frontend (.env.local)

Create `frontend/.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## Next Steps

1. **Database**: All data is stored in SQLite3 locally
2. **Media**: Product images stored in `backend/media/`
3. **Authentication**: JWT-based authentication (no external service)
4. **Development**: Both servers run independently on localhost

## Support

For issues or questions:
- Check Django logs: `python manage.py runserver --verbosity=2`
- Check browser console for frontend errors
- Verify environment variables are set correctly

