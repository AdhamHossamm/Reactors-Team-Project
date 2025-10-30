# 🚀 Installation Guide for Friends

**Super simple, step-by-step guide for people new to Docker.**

---

## ⏱️ Total Time: 10 minutes

---

## STEP 1: Install Docker Desktop (5 minutes)

### 1.1 Download Docker

Visit: https://www.docker.com/products/docker-desktop/

Click "Download for Windows"

### 1.2 Install

1. Run the downloaded installer
2. **Accept all defaults** (just click Next)
3. **Restart** when prompted
4. Wait for Docker Desktop to start

### 1.3 Verify Installation

Look for this icon in your system tray (bottom right):

```
🐳 Docker Desktop icon
```

**How to know it's ready:**
- Icon is steady (not animating)
- No error messages
- Can click on it and see "Docker Desktop is running"

**Troubleshooting:**
- If icon keeps animating, wait 2-3 minutes
- If you see "WSL 2 update required", click "Update"
- If installation fails, make sure virtualization is enabled in BIOS

---

## STEP 2: Get the Project (1 minute)

### Option A: Downloaded ZIP
1. Download the ZIP file from your friend
2. Right-click → "Extract All..."
3. Choose any folder (Desktop is fine)

### Option B: USB Drive
1. Insert USB drive
2. Copy project folder to desktop
3. Done

---

## STEP 3: Run the Project (1 minute)

1. **Open** the project folder
2. **Find** the file called `START.bat`
3. **Double-click** it
4. **Wait** 2-3 minutes (first time only)

A window will open showing progress:
```
Building backend...
Building frontend...
Starting containers...
```

When you see:
```
✓ SUCCESS! Containers are running
```

**YOU'RE DONE!** 🎉

Your browser will open automatically at http://localhost:3000

---

## STEP 4: Log In (30 seconds)

Use any of these test accounts:

### Admin Account
```
Email: admin@example.com
Password: admin
```

### Seller Account
```
Email: seller@example.com
Password: seller123
```

### Buyer Account
```
Email: buyer@example.com
Password: buyer123
```

---

## 🎯 That's It!

You now have a full e-commerce platform running on your computer!

**No coding knowledge needed.**
**No manual setup.**
**Everything works automatically.**

---

## 💡 What You Can Do

### Browse the Store
- Go to "Shop" in the navigation
- Browse products
- Add items to cart
- Checkout (buyer account)

### Manage Products
- Log in as seller
- Go to "My Products"
- Add/edit/delete products

### Admin Access
- Log in as admin
- Go to http://localhost:3000/admin
- Full system control

---

## 🛑 How to Stop

### Stop the App
1. Go to the terminal window running START.bat
2. Press `Ctrl + C`
3. Containers stop

OR

1. Double-click `STOP.bat`

### Start Again Later
Just double-click `START.bat` again

**Your data is saved!** Everything persists.

---

## 🔄 Fresh Start (Delete All Data)

Want to start completely fresh?

1. Double-click `RESTART-FRESH.bat`
2. Confirm when asked
3. Wait for rebuild

**Warning:** This deletes all products, orders, and user data.

---

## ❓ Troubleshooting

### Problem: "Docker is not running"

**Solution:**
1. Click the Docker icon in system tray
2. Click "Docker Desktop"
3. Wait for it to fully start
4. Try START.bat again

### Problem: "Port already in use"

**Solution:**
1. Close any other apps
2. In START.bat window, press `Ctrl + C`
3. Try again

### Problem: Browser says "Can't connect"

**Solution:**
1. Wait 30 seconds after START.bat finishes
2. Manually go to: http://localhost:3000
3. Refresh the page

### Problem: Build fails

**Solution:**
1. Make sure Docker Desktop is fully running
2. Run RESTART-FRESH.bat
3. Try again

---

## 📁 File Guide

### Important Files

**START.bat** - Launches everything (use this!)

**STOP.bat** - Stops the application

**RESTART-FRESH.bat** - Deletes everything and restarts

**README-FOR-FRIEND.txt** - Quick reference

### Don't Worry About These

All other files are for the application. You don't need to touch them.

---

## 🎓 Learning More

Curious how this works?

- **DOCKER-SETUP.md** - Technical details
- **HOW-TO-SHARE.md** - Guide for sharing Docker projects

---

## ✅ Quick Reference

**Start application:**
```
Double-click START.bat
```

**Stop application:**
```
Press Ctrl+C or double-click STOP.bat
```

**Start fresh:**
```
Double-click RESTART-FRESH.bat
```

**Access URLs:**
```
Store:      http://localhost:3000
Admin:      http://localhost:8000/admin
API:        http://localhost:8000
```

**Login (any account works):**
```
admin@example.com  /  admin
seller@example.com / seller123
buyer@example.com  / buyer123
```

---

## 🎉 Congratulations!

You just ran a complex full-stack application with Docker!

**No programming needed.**
**No configuration needed.**
**Just one click and everything works.**

Welcome to the power of Docker! 🐳

---

**Questions?** Tell your friend to check the terminal logs:
```
docker compose logs -f
```

