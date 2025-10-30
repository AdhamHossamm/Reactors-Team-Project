# ⚛️ REACTORS — Professional E-Commerce Platform

Enterprise-grade full-stack e-commerce platform built with **Next.js 15**, **Django 5**, and **Supabase PostgreSQL**.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   REACTORS Platform                          │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────▼────────────┐
         │  Render.com Web Service │
         │  ┌──────────────────┐  │
         │  │ Next.js Frontend │  │
         │  │ Django Backend   │  │
         │  │ Django Admin     │  │
         │  └──────────────────┘  │
         └───────────┬─────────────┘
                     │
         ┌───────────▼────────────┐
         │  Supabase PostgreSQL   │
         │  (Production Database) │
         └────────────────────────┘
```

## 🚀 Quick Start

### 🌐 Production Deployment (Render.com + Supabase)

**Deploy REACTORS to production in 15 minutes!**

See complete guide: **[DEPLOYMENT.md](DEPLOYMENT.md)**

Quick summary:
1. Create Supabase project & deploy schema
2. Push code to GitHub
3. Deploy to Render.com with environment variables
4. Done! ✅

---

### 💻 Local Development Setup

### Prerequisites
- **Python 3.11+**
- **Node.js 18+**
- **SQLite3** (included with Python)

### Backend Setup

```bash
cd backend

# Install dependencies
pip install -r requirements.txt

# Run migrations
python manage.py migrate

# Create test accounts
python manage.py setup_local

# Start server
python manage.py runserver
```

Backend will be available at: **http://localhost:8000**
- Admin Panel: http://localhost:8000/admin/
- API Docs: http://localhost:8000/api/schema/swagger-ui/

### Frontend Setup
```bash
cd frontend

# Install dependencies
npm install

# Create environment file (optional)
cp .env.example .env.local

# Start development server
npm run dev
```

Frontend will be available at: **http://localhost:3000**

### Test Accounts

- **Admin**: admin@example.com / admin
- **Superuser**: superuser@example.com / superuser  
- **Seller**: seller@example.com / seller123
- **Buyer**: buyer@example.com / buyer123

For detailed setup instructions, see [LOCAL-SETUP-GUIDE.md](LOCAL-SETUP-GUIDE.md)

## 📁 Project Structure

```
root/
├─ backend/                 # Django 5 + DRF 3.15
│   ├─ config/              # Project settings
│   ├─ users/               # User authentication & profiles
│   ├─ products/            # Product catalog & reviews
│   ├─ orders/              # Cart & order management
│   ├─ sellers/             # Seller profiles & payouts
│   ├─ analytics/           # Analytics & tracking
│   ├─ adminpanel/          # Admin customizations
│   ├─ requirements.txt     # Python dependencies
│   └─ Dockerfile           # Production image
│
├─ frontend/                # Next.js 14 + React 19.1.1
│   ├─ app/                 # App Router pages
│   ├─ components/          # Reusable UI components
│   ├─ services/            # API clients
│   ├─ store/               # Zustand state management
│   ├─ package.json         # Node dependencies
│   └─ Dockerfile.dev       # Development image
│
├─ supabase/                # Supabase Edge Functions
│   ├─ functions/           # Edge Function handlers
│   └─ config.toml          # Supabase configuration
│
├─ docs/                    # Documentation
│   └─ adr/                 # Architecture Decision Records
│
├─ docker-compose.yml       # Local development orchestration
└─ .github/workflows/       # CI/CD pipelines
```

## 🔧 Tech Stack

### Frontend
- **React 19.1.1** — UI library
- **Next.js 14** — React framework with SSR/ISR
- **TypeScript 5.7** — Type safety
- **Tailwind CSS 3.4** — Utility-first styling
- **Zustand 5.0** — State management
- **Axios 1.7** — HTTP client
- **@supabase/supabase-js 2.42** — Supabase client

### Backend
- **Django 5.0** — Web framework
- **Django REST Framework 3.15** — API toolkit
- **djangorestframework-simplejwt 5.3** — JWT authentication
- **django-cors-headers 4.3** — CORS handling
- **PostgreSQL 16** — Primary database
- **Gunicorn 22.0** — WSGI server

### Edge Compute
- **Supabase Edge Functions** — Serverless functions (Deno runtime)

### DevOps
- **Docker** — Containerization
- **GitHub Actions** — CI/CD
- **Vercel** — Frontend deployment
- **Render** — Backend deployment

## 📚 API Documentation

Once the backend is running, access the API documentation:
- **Swagger UI:** http://localhost:8000/api/schema/swagger-ui/
- **ReDoc:** http://localhost:8000/api/schema/redoc/

## 🧪 Testing

### Backend Tests
```bash
cd backend
python manage.py test
coverage run --source='.' manage.py test
coverage report
```

### Frontend Tests
```bash
cd frontend
npm test
npm run test:coverage
```

### E2E Tests
```bash
npm run test:e2e
```

## 🔒 Security

- **JWT Authentication** with 60-minute access tokens
- **CORS** configured with explicit allow-list
- **HTTPS** required in production
- **Service-role keys** for Supabase webhooks
- **Environment variables** for secrets
- **Rate limiting** on API endpoints

## 📊 Monitoring

- **Sentry** — Error tracking
- **Grafana** — Metrics dashboards
- **Supabase Dashboard** — Edge function logs

## 🚢 Deployment

### Production (Render.com + Supabase)

**Complete deployment guide:** [DEPLOYMENT.md](DEPLOYMENT.md)

Quick steps:
1. **Supabase**: Create project, deploy schema
2. **Render.com**: Connect GitHub, configure, deploy
3. **Verify**: Test API, admin, database

**Live in 15 minutes!** ⚡

## 📖 Documentation

- [Architecture Decision Records](docs/adr/)
- [API Documentation](http://localhost:8000/api/schema/)
- [Supabase Functions](supabase/functions/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License.

## 👥 Team

**Project:** REACTORS  
**Principal Engineer:** Adam  
**Toolchain:** Cursor (Sonnet 4.5 / Claude)

---

**⚛️ REACTORS — Built with modern full-stack technologies**

