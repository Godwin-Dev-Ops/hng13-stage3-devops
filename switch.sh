#!/bin/bash
# =====================================================
# HNG Stage 2 - Blue/Green Deployment Switch Script
# =====================================================

# Load current .env values
source .env

echo "==============================================="
echo "🔄 Starting Blue-Green Switch Process"
echo "==============================================="
echo "Current ACTIVE_POOL: $ACTIVE_POOL"
echo "-----------------------------------------------"

# Determine new pool
if [ "$ACTIVE_POOL" = "blue" ]; then
  NEW_POOL="green"
else
  NEW_POOL="blue"
fi

# Update .env file
sed -i "s/ACTIVE_POOL=.*/ACTIVE_POOL=$NEW_POOL/" .env
echo "✅ Updated .env → ACTIVE_POOL=$NEW_POOL"

# Restart nginx service to apply new config
echo "🚀 Restarting nginx container..."
docker compose up -d --force-recreate nginx

# Wait a moment for reload
sleep 3

# Test the connection
echo "-----------------------------------------------"
echo "🌍 Testing Nginx on port 8080..."
curl -s http://localhost:8080 | head -n 5
echo "-----------------------------------------------"
echo "✅ Deployment switched successfully!"
echo "Now active pool: $NEW_POOL"
echo "==============================================="

