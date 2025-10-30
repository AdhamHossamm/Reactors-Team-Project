# Project Setup Guide

## Quick Start

1. **Run the project**:

   ```bash
   # Double-click on START-PROJECT.bat
   # OR run from command line:
   START-PROJECT.bat
   ```

2. **Access the application**:
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:8000
   - Django Admin: http://localhost:8000/admin/
   - Admin Login: admin@example.com (password: admin)

## Manual Setup (if needed)

### Backend Setup

```bash
cd backend
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
python manage.py migrate
python manage.py createsuperuser
python manage.py runserver
```

### Frontend Setup

```bash
cd frontend
npm install --legacy-peer-deps
npm run dev
```

## Project Information

- **Backend**: Django 5.0 + Django REST Framework
- **Frontend**: Next.js 15 + React 19
- **Database**: SQLite (local development)
- **Authentication**: JWT tokens

## Features

- User authentication
- Product catalog
- Shopping cart
- Order management
- Seller dashboard
- Admin panel
- Analytics

## Notes

- The project uses SQLite for local development
- Supabase integration is configured but requires credentials
- Frontend dependencies use `--legacy-peer-deps` flag due to React 19 compatibility

## Troubleshooting

### Backend won't start

- Make sure Python 3.11+ is installed
- Activate virtual environment: `.\venv\Scripts\activate`
- Install dependencies: `pip install -r requirements.txt`

### Frontend won't start

- Make sure Node.js 20+ is installed
- Install dependencies: `npm install --legacy-peer-deps`
- Check if port 3000 is available

### Database issues

- Delete `db.sqlite3` and run `python manage.py migrate` again

## Project Structure

```
backend/          # Django backend
frontend/         # Next.js frontend
docs/            # Documentation
supabase/        # Supabase configuration
```

