# Supabase Edge Functions

This directory contains Supabase Edge Functions for the e-commerce platform.

## Functions

### 1. order_status_update
Triggered by Django webhook when order status changes. Logs events and sends notifications.

### 2. cart_activity_log
Logs cart activities (add, remove, update, checkout) for analytics.

### 3. product_sync
Publishes real-time inventory updates to Supabase Realtime.

### 4. notify_user
Sends transactional emails or push notifications to users.

## Development

```bash
# Start local Supabase
npx supabase start

# Serve functions locally
npx supabase functions serve

# Deploy to production
npx supabase functions deploy
```

## Authentication

All Edge Functions use service-role key authentication. Webhooks from Django must include:
- HMAC signature in header, OR
- Service-role JWT token

