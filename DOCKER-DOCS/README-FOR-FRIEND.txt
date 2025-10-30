====================================
E-COMMERCE PLATFORM - QUICK START
====================================

🎯 GOAL: Run this project with ONE CLICK!
       No programming knowledge needed!

====================================
REQUIREMENTS
====================================
✓ Windows 10/11 (64-bit)
✓ 8GB RAM minimum
✓ Docker Desktop (download link below)

====================================
STEP 1: INSTALL DOCKER
====================================

1. Download Docker Desktop:
   https://www.docker.com/products/docker-desktop/

2. Install it (use default settings)

3. Start Docker Desktop
   - Wait for the Docker icon in system tray
   - It must be running (not just installed)

====================================
STEP 2: RUN THE PROJECT
====================================

1. Extract this ZIP file

2. Double-click: START.bat

3. Wait 2-3 minutes (first time only)

4. Your browser will open automatically!
   If not, go to: http://localhost:3000

THAT'S IT! 🎉

====================================
WHAT HAPPENS AUTOMATICALLY
====================================

✓ Downloads Python 3.11 (backend)
✓ Downloads Node.js 18 (frontend)
✓ Installs all dependencies (500+ packages)
✓ Sets up database
✓ Creates test accounts
✓ Starts both servers

You don't need to install Python, Node.js, or anything else!

====================================
ACCESS POINTS
====================================

Frontend:    http://localhost:3000
Backend API: http://localhost:8000
Admin Panel: http://localhost:8000/admin/

====================================
TEST ACCOUNTS
====================================

Admin Account:
  Email: admin@example.com
  Password: admin
  Access: Everything (full control)

Seller Account:
  Email: seller@example.com
  Password: seller123
  Access: Sell products, manage orders

Buyer Account:
  Email: buyer@example.com
  Password: buyer123
  Access: Browse, add to cart, checkout

====================================
USEFUL FILES
====================================

START.bat          - Main start script (use this!)
START-QUICK.bat    - Quick start (no extra info)
STOP.bat           - Stop all containers
RESTART-FRESH.bat  - Delete everything and restart

====================================
TROUBLESHOOTING
====================================

PROBLEM: "Docker is not running"
SOLUTION: Start Docker Desktop app first

PROBLEM: Port already in use
SOLUTION: Close any apps using ports 3000 or 8000

PROBLEM: Build fails
SOLUTION: Make sure Docker Desktop is fully started
          (look for Docker icon in system tray)

PROBLEM: Can't connect
SOLUTION: Wait 30 seconds after START.bat finishes
          Containers need time to fully boot up

PROBLEM: Want to start over
SOLUTION: Run RESTART-FRESH.bat
          This deletes all data and rebuilds

====================================
VIEW LOGS
====================================

See what's happening inside containers:
  1. Open new terminal in this folder
  2. Type: docker compose logs -f

Stop logs: Press Ctrl+C

====================================
STOP THE APPLICATION
====================================

Option 1: Close the terminal window (Ctrl+C)

Option 2: Double-click STOP.bat

Data is saved automatically!

====================================
IMPORTANT NOTES
====================================

1. Keep Docker Desktop running
2. First start takes 2-3 minutes (downloads everything)
3. Subsequent starts take 10-20 seconds
4. Your changes are saved automatically
5. All data persists between restarts

====================================
TECHNICAL DETAILS (Optional)
====================================

This project uses:
- Django 5 (Python backend)
- Next.js 15 (React frontend)
- SQLite3 (database)
- Docker Compose (container orchestration)

Everything runs in isolated containers.
Your computer doesn't need Python or Node.js installed.

====================================
QUESTIONS?
====================================

Check: DOCKER-SETUP.md (detailed guide)

Common commands:
- View running containers: docker ps
- View logs: docker compose logs -f
- Stop everything: docker compose down
- Fresh start: docker compose down -v

====================================
ENJOY! 🚀
====================================

