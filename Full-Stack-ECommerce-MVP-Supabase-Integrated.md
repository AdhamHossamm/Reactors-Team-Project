# 🏗️ Full-Stack E-Commerce MVP — Amazon Skeleton Edition (Supabase Integrated)
### React 19.1.1 + Next.js 14 + Django 5 + DRF 3.15 + PostgreSQL 16 + Supabase Edge Functions
**Author:** Adam  
**Role:** Principal Software Engineer  
**Toolchain:** Cursor (Sonnet 4.5 / Claude)  
**Purpose:** Enterprise-grade, modular architecture for a scalable e‑commerce platform inspired by Amazon’s ecosystem, now enhanced with Supabase Edge Functions for distributed compute and real‑time responsiveness.

---

## 1️⃣ Executive Summary
This document defines a **full‑stack engineering blueprint** that fuses **Supabase Edge Functions** into the existing Django + Next.js ecosystem without compromising architectural cohesion.  
It maintains PostgreSQL as the single source of truth and extends the runtime with Supabase’s globally distributed edge compute for high‑speed, event‑driven tasks.

---

## 2️⃣ System Context Overview

### Primary Components
| Layer | Technology | Responsibility |
|-------|-------------|----------------|
| **Frontend** | React 19.1.1 + Next.js 14 | UI/UX, SSR, ISR, API orchestration |
| **Backend Core** | Django 5 + DRF 3.15 | Business logic, Auth, API, ORM |
| **Database** | PostgreSQL 16 | Primary relational store |
| **Edge Compute** | Supabase Edge Functions | Event hooks, async compute, real‑time operations |
| **Cache** | Redis (optional) | Hot query caching, sessions |
| **Deployment** | Vercel (frontend) + Render (backend) + Supabase (Edge) | Cloud runtime distribution |
| **Testing / CI** | GitHub Actions | Automated builds and deployments |

---

## 3️⃣ Architectural Philosophy
- **Monolithic core + Edge extension:** Django remains authoritative over data and auth; Supabase extends compute to the edge for speed and locality.  
- **Single source of truth:** PostgreSQL instance managed by Django, exposed through both DRF and Supabase for unified access.  
- **Loose coupling:** Each service deploys independently and communicates through HTTPS / JWT‑secured APIs.  
- **Observability‑ready:** Logging, tracing, and metrics baked into every layer.  

---

## 4️⃣ High‑Level Data Flow

```
[ Client (Next.js) ]
        ↓
[ API Gateway Layer ]
   ├── Django REST API → Core CRUD + Auth + Orders
   └── Supabase Edge → Event hooks / Real‑time feeds / Analytics
        ↓
[ PostgreSQL 16 ]
        ↓
[ Redis Cache (Optional) ]
```

---

## 5️⃣ Detailed Module Breakdown

### 🔹 Django Core Backend
Handles critical persistence and orchestration logic.
- Apps: `users`, `products`, `orders`, `sellers`, `adminpanel`, `analytics`
- JWT authentication via `djangorestframework‑simplejwt`
- ORM models maintain referential integrity with Postgres

### 🔹 Supabase Edge Functions
Event‑driven micro‑services deployed near users.
Use cases:
- `order_status_update`: emit webhooks on status changes  
- `cart_activity_log`: record cart behavior for analytics  
- `product_sync`: push real‑time stock updates  
- `notify_user`: send transactional emails or web‑push

Each function is built in TypeScript or Deno runtime.

### 🔹 Next.js Frontend
- React 19.1.1 App Router for UI composition  
- Zustand store for global state  
- Axios + `@supabase/supabase-js` for dual API communication  
- SSR + ISR for SEO and performance  

---

## 6️⃣ Supabase Integration Strategy

### Data Ownership
- Django ORM → Primary write path to PostgreSQL.  
- Supabase → Read / listen via replication and Realtime API.  
- Edge Functions → Execute async jobs that reference Django’s API or Supabase client.

### Communication Contracts
| Direction | Protocol | Purpose |
|------------|-----------|----------|
| Frontend → Django | REST (Axios) | CRUD, auth, checkout |
| Frontend → Supabase | HTTPS (supabase-js) | Real‑time actions |
| Django → Supabase Edge | Webhook / HTTP | Post‑order or analytics triggers |
| Supabase Edge → DB | Direct Postgres / RPC | Data logging |

---

## 7️⃣ Folder Structure (Unified)

```
root/
├─ frontend/                # Next.js 19 + Zustand
│   ├─ src/
│   │   ├─ app/
│   │   ├─ components/
│   │   ├─ services/
│   │   ├─ store/
│   │   └─ styles/
│   └─ next.config.js
│
├─ backend/                 # Django Core Logic
│   ├─ core/
│   ├─ users/
│   ├─ products/
│   ├─ orders/
│   ├─ sellers/
│   ├─ analytics/
│   ├─ api/
│   └─ requirements.txt
│
└─ supabase/
    ├─ functions/
    │   ├─ order_status_update/
    │   ├─ cart_activity_log/
    │   ├─ product_sync/
    │   └─ notify_user/
    ├─ supabase/config.toml
    └─ package.json
```

---

## 8️⃣ Dependency Registry

### Frontend `package.json`
```json
{
  "dependencies": {
    "next": "^14.x",
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "axios": "^1.7.x",
    "@supabase/supabase-js": "^2.42.x",
    "zustand": "^5.0.x",
    "clsx": "^2.x"
  },
  "devDependencies": {
    "eslint": "^9.x",
    "typescript": "^5.x",
    "prettier": "^3.x"
  }
}
```

### Backend `requirements.txt`
```
Django>=5.0,<6.0
djangorestframework>=3.15,<4.0
djangorestframework-simplejwt>=5.3
django-cors-headers>=4.3
psycopg2-binary>=2.9
python-dotenv>=1.0
gunicorn>=22.0
```

### Supabase Functions `package.json`
```json
{
  "dependencies": {
    "@supabase/functions-js": "^2.x",
    "axios": "^1.7.x"
  }
}
```

---

## 9️⃣ Environment Variables

### Frontend `.env.local`
```
NEXT_PUBLIC_API_URL=https://api.domain.com
NEXT_PUBLIC_SUPABASE_URL=https://xyzcompany.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

### Backend `.env`
```
SECRET_KEY=your_secret_key
DATABASE_URL=postgres://user:pass@host:5432/db
ALLOWED_HOSTS=*
CORS_ALLOWED_ORIGINS=["https://frontend-domain.com"]
SUPABASE_SERVICE_KEY=your-service-role-key
SUPABASE_URL=https://xyzcompany.supabase.co
```

---

## 🔟 CI/CD & Deployment Workflow

```yaml
name: FullStack CI/CD
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Backend Test
        run: |
          cd backend
          pip install -r requirements.txt
          python manage.py test
      - name: Frontend Build
        run: |
          cd frontend
          npm ci
          npm run build
      - name: Deploy Supabase Functions
        run: |
          cd supabase
          npx supabase functions deploy --project-ref xyzcompany
```

---

## 1️⃣1️⃣ Security & Governance
- JWTs signed by Django; Supabase verifies via secret key.  
- Use **Role‑Based Access Control (RBAC)** within Django.  
- All Edge Functions authenticated with service‑role key.  
- CORS configured across all endpoints.  
- Data encryption in‑transit (HTTPS / TLS 1.3).  

---

## 1️⃣2️⃣ Scalability Considerations
- Horizontal scaling of Django via Render autoscale.  
- Supabase Edge handles global request bursts.  
- Next.js ISR for dynamic product caching.  
- Postgres read‑replicas for analytics workloads.  
- Eventual consistency model for non‑critical logs.  

---

## 1️⃣3️⃣ Cursor Prompts

### Backend Prompt
```
You are a Principal Django Architect.
Generate a modular DRF backend integrated with Supabase Edge Functions.
Requirements:
- PostgreSQL ORM
- JWT auth
- REST endpoints for users, products, orders, sellers
- Webhook to trigger Supabase Edge Function (order_status_update)
- Environment variable loading via dotenv
```

### Frontend Prompt
```
You are a Senior Next.js Engineer.
Create a Next.js 14 app (React 19.1.1) with Supabase integration.
Implement:
- SSR home and product pages
- Zustand for global cart state
- Axios for Django API calls
- @supabase/supabase-js for edge requests and real‑time updates
- Secure .env variable usage
```

### Supabase Prompt
```
You are a Supabase Edge Engineer.
Create and deploy the following functions:
- order_status_update → Triggered by Django webhook on order status change
- cart_activity_log → Listens to cart updates and stores analytics
- product_sync → Publishes inventory updates to Supabase Realtime
Ensure TypeScript runtime and deploy with supabase CLI.
```

---

## 1️⃣4️⃣ Development Commands

**Backend**
```bash
pip install -r backend/requirements.txt
python manage.py migrate
python manage.py runserver
```

**Frontend**
```bash
cd frontend
npm install
npm run dev
```

**Supabase Edge Functions**
```bash
cd supabase
npx supabase start
npx supabase functions deploy
```

---

## 1️⃣5️⃣ Future Roadmap
- Introduce GraphQL gateway for cross‑service queries  
- Integrate Celery + Supabase Queues for async processing  
- Add AI‑based recommendations via Edge Models  
- Implement multi‑tenant support with Supabase auth scopes  
- Enable real‑time inventory dashboard through Supabase Subscriptions  

---

## ✅ Summary
This document establishes a **production‑ready hybrid architecture** where **Django** governs business logic, **Supabase Edge Functions** deliver near‑instant event responses, and **Next.js 19 frontend** unifies the user experience.  
The design ensures durability, scalability, and extensibility consistent with Amazon‑grade e‑commerce standards.

---

**// Generated by AdhamSonnet‑4.5 — Principal Engineering Methodology Edition**
