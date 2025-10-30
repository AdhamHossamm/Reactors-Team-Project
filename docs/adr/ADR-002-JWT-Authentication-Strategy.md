# ADR-002: JWT Authentication Strategy

**Status:** Accepted  
**Date:** 2025-10-24  
**Decision Makers:** Principal Engineering Team

## Context

The platform requires secure authentication across:
- Django REST API (backend)
- Next.js frontend (client-side)
- Supabase Edge Functions (webhooks)

## Decision

We will use **JWT (JSON Web Tokens)** with the following strategy:

### Token Issuance
- **Django** issues JWTs via `djangorestframework-simplejwt`
- Access tokens: 60 minutes lifetime
- Refresh tokens: 7 days lifetime
- Tokens include: `user_id`, `email`, `role` (buyer/seller/admin)

### Token Validation
- **Frontend:** Stores tokens in memory (Zustand store)
- **Django API:** Validates JWT on every request
- **Supabase Edge:** Validates service-role key (not user JWT)

### Token Rotation
- Refresh tokens are rotated on use
- Old refresh tokens are blacklisted after rotation

## Consequences

### Positive
- ✅ Stateless authentication (no session storage)
- ✅ Works across distributed systems
- ✅ Role-based access control (RBAC) in token claims
- ✅ Automatic expiration

### Negative
- ⚠️ Cannot revoke tokens before expiration (mitigated with short lifetime)
- ⚠️ Token size larger than session ID

### Security Considerations
- Secret key must be rotated quarterly
- HTTPS required for all token transmission
- Tokens stored in memory (not localStorage) to prevent XSS
- CORS configured to prevent CSRF

## Alternatives Considered

1. **Session-based auth:** Requires sticky sessions, not suitable for distributed systems
2. **OAuth 2.0:** Overkill for MVP, adds complexity
3. **Supabase Auth:** Would require dual auth systems

## Implementation Notes

- Use `djangorestframework-simplejwt` library
- Frontend Axios interceptor auto-refreshes tokens
- Service-role key for Django → Supabase webhooks

