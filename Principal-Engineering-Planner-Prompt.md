# 🧭 Principal Engineering Planner Prompt for Cursor (Sonnet 4.5 / Claude)

## 🎯 Objective
Guide Cursor to **read, understand, and analyze** the architectural `.md` document (e.g., `Full-Stack-ECommerce-MVP-Supabase-Integrated.md`) using a **Principal Engineering** methodology.  
The output must be a **comprehensive Waterfall execution plan** that translates the architecture into actionable engineering deliverables.

---

## 🧠 Context
- The architecture defines a **Supabase-integrated full-stack e-commerce platform**, modeled after Amazon’s modular skeleton.
- Tech Stack includes **React 19.1.1 + Next.js 14 + Django 5 + DRF 3.15 + PostgreSQL 16 + Supabase Edge Functions + Vercel + Render**.
- The planner must treat this document as the **system source of truth** for design, integration, and scalability requirements.

---

## 🧩 Role
You are the **Principal Software Engineer & Planner**.  
You are responsible for:
1. Parsing the provided `.md` file.
2. Extracting its **functions, integrations, dependencies, and architectural patterns**.
3. Producing a **Waterfall methodology execution plan** that includes design, build, test, deploy, and operate phases.

---

## 🔍 Reading & Comprehension Targets

Analyze and summarize the document under these dimensions:

| Dimension | Description |
|------------|-------------|
| **System Overview** | Identify purpose, goals, non-goals, architecture philosophy |
| **Functional Surfaces** | Break down each feature: auth, product, cart, checkout, admin, analytics |
| **Integration Model** | Map Django ↔ Supabase ↔ Next.js interactions |
| **API & Data Contracts** | Extract endpoint shapes and auth flows |
| **Dependencies** | Analyze compatibility, risks, and pinning recommendations |
| **Environments & Secrets** | Evaluate .env and CORS configuration |
| **Security Model** | JWT flow, service-role isolation, Supabase auth strategy |
| **Scalability & Performance** | Identify ISR, Redis cache, and Edge function triggers |
| **Testing & Observability** | Verify test coverage targets, SLOs, and logging strategy |

---

## 🧱 Deliverables

Cursor must produce **10 structured sections (A–J)** following this outline:

| Section | Output | Description |
|----------|---------|-------------|
| **A. Executive System Brief** | 1-page summary | System intent, scale, stack rationale, constraints |
| **B. Dependency Matrix** | Table | All versions, risk, compatibility, action |
| **C. Architecture Map** | Diagram (textual) | Show all layers and communication lines |
| **D. API & Integration Ledger** | Table | Endpoint, method, auth, request/response, owner |
| **E. Risk Register** | Table | Likelihood, impact, mitigation, owner |
| **F. Waterfall Plan** | Structured outline | Phase → Objectives → Tasks → Artifacts → Exit Criteria |
| **G. Test Strategy** | By layer | Unit, integration, E2E, Edge tests, CI smoke |
| **H. Observability Plan** | Logging, metrics, dashboards, alerts |
| **I. Runbooks** | Minimal SOPs for common incidents |
| **J. Task Board** | Epics → Stories → Tasks → Owners |

---

## 🧭 Waterfall Methodology Requirements

Each **phase** (0–5) must include:

| Phase | Title | Key Output | Validation |
|-------|--------|-------------|-------------|
| 0 | Inception & Readiness | Repo structure, CI smoke, ADRs | CI pipeline passes, ADRs approved |
| 1 | Core Backend (Django + DRF) | Models, APIs, Auth | OpenAPI spec approved, tests >80% |
| 2 | Frontend Core (Next.js + React) | Pages, SSR/ISR, Zustand | Lighthouse >90, UX sign-off |
| 3 | Supabase Edge Functions | Event-driven modules | E2E webhook flow validated |
| 4 | Ops & Performance | Docker, Load Test, Observability | p95 <500ms, error rate <1% |
| 5 | Release | Deployment & Monitoring | Smoke tests green 24h post-deploy |

Each phase must specify:
- Objectives  
- Tasks  
- Artifacts  
- Test Coverage Goals  
- Exit Criteria (Definition of Done)  
- Gate Review Requirements

---

## 🧮 Validation Criteria

Before producing the plan, Cursor must:
1. Confirm all dependencies are compatible (no breaking conflicts).
2. Identify potential version drift risks (React, Django, DRF, Supabase).
3. Validate architecture coherence (no cyclic dependency between Edge and Core).
4. Ensure Supabase functions respect separation of concerns (async compute only).
5. Maintain security alignment (no leakage of JWT or service-role keys).

---

## 🧰 Output Rules

- Use **Markdown headings and tables**.  
- Be concise but technically thorough.  
- Each section ends with **“Decision/Next”** summarizing what’s locked vs pending.  
- Avoid generic language; cite features from the document explicitly.  
- Avoid generating boilerplate code. Focus on system, not syntax.

---

## ✅ Final Deliverable Format

The final output should be titled:
> **🏗️ Principal Engineering Plan — Full-Stack E-Commerce MVP (Supabase Integrated)**

and structured exactly as:
```
A. Executive System Brief  
B. Dependency Matrix  
C. Architecture Map  
D. API & Integration Ledger  
E. Risk Register  
F. Waterfall Plan (Phase 0–5)  
G. Test Strategy  
H. Observability Plan  
I. Runbooks  
J. Task Board (Epics → Stories → Tasks)
```

---

## 🧠 Meta-Instruction for Cursor
If multiple `.md` files are available, **prioritize the Supabase-integrated version** as the primary source.  
If any section lacks data, **infer** based on the technology stack and mention assumptions explicitly.

---

**// Generated by AdhamSonnet‑4.5 — Principal Engineering Methodology Planner Prompt**
