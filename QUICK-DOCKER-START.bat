@echo off
echo ========================================
echo Starting E-Commerce Platform with Docker
echo ========================================
echo.
echo This will build and start all services.
echo First time may take a few minutes...
echo.
echo Press any key to continue or Ctrl+C to cancel...
pause >nul
echo.
echo Building and starting containers...
docker-compose up --build
echo.
echo Done! Containers are running.
echo.
echo Access your application:
echo   Frontend: http://localhost:3000
echo   Backend:  http://localhost:8000
echo   Admin:    http://localhost:8000/admin/
echo.
echo Test accounts (auto-created):
echo   Admin: admin@example.com / admin
echo   Seller: seller@example.com / seller123
echo   Buyer: buyer@example.com / buyer123
echo.
echo Press any key to stop containers...
pause >nul
docker-compose down


