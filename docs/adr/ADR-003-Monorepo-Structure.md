# ADR-003: Monorepo Structure

**Status:** Accepted  
**Date:** 2025-10-24  
**Decision Makers:** Principal Engineering Team

## Context

The e-commerce platform consists of three distinct layers:
- **Backend:** Django 5 + DRF 3.15
- **Frontend:** Next.js 14 + React 19.1.1
- **Edge Compute:** Supabase Edge Functions

We need to decide on repository structure.

## Decision

We will use a **monorepo structure** with the following layout:

```
root/
├─ frontend/        # Next.js app
├─ backend/         # Django project
├─ supabase/        # Edge Functions
├─ docs/            # Documentation & ADRs
├─ docker-compose.yml
└─ .github/workflows/  # CI/CD
```

### Rationale
- **Atomic commits** across frontend/backend/edge
- **Shared CI/CD pipeline** for all layers
- **Single source of truth** for documentation
- **Simplified dependency management**

## Consequences

### Positive
- ✅ Easier to coordinate breaking changes
- ✅ Single PR for full-stack features
- ✅ Shared tooling (Docker, CI/CD)
- ✅ Better discoverability

### Negative
- ⚠️ Larger repository size
- ⚠️ Need clear separation of concerns
- ⚠️ CI/CD must intelligently detect changes

### Best Practices
- Each layer has its own `.gitignore`
- Each layer has its own `README.md`
- CI/CD uses path filters to run relevant tests
- Docker Compose for local development

## Alternatives Considered

1. **Polyrepo (separate repos):** Harder to coordinate, more overhead
2. **Monolith (single Django + templates):** Not suitable for modern SPA

## Implementation Notes

- Use GitHub Actions with path filters
- Docker Compose orchestrates all services
- Each layer independently deployable

