#!/usr/bin/env bash
# REACTORS Build Script for Render.com
set -o errexit

echo "🚀 REACTORS Build Starting..."

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install -r backend/requirements.txt

# Collect static files
echo "📁 Collecting static files..."
cd backend
python manage.py collectstatic --noinput

# Run migrations
echo "🗄️  Running database migrations..."
python manage.py migrate

echo "✅ REACTORS Build Complete!"

