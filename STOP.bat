@echo off
title Stopping Containers
color 0C

echo Stopping all containers...
docker compose down

echo.
echo [✓] All containers stopped.

pause



