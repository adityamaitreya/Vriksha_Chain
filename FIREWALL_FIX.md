# ⚠️ Firewall Configuration Needed

## Current Status:
- ✅ Ganache is running
- ✅ Listening on: 0.0.0.0:8545 (all interfaces)
- ✅ Accessible from localhost (127.0.0.1)
- ❌ Blocked from network (192.168.0.215)

## The Problem:
Windows Firewall is blocking incoming connections on port 8545 from your phone.

---

## 🛡️ Solution: Allow Port 8545 Through Firewall

### Option 1: Quick Test (Turn Off Firewall Temporarily)

**⚠️ Only for testing! Turn it back on after.**

1. Open **Windows Security**
2. Click **Firewall & network protection**
3. Click **Private network** (or whichever is active)
4. Turn off **Microsoft Defender Firewall**
5. Test your app
6. **Remember to turn it back on!**

---

### Option 2: Add Firewall Rule (Recommended)

**You'll need Administrator rights for this.**

#### Step-by-Step:

1. **Open Windows Security**
   - Press `Windows + I` → Security → Windows Security
   - Or search for "Windows Defender Firewall"

2. **Click "Advanced settings"** (on the left)

3. **Click "Inbound Rules"** (on the left)

4. **Click "New Rule..."** (on the right)

5. **Select "Port"** → Next

6. **Select "TCP"**
   - Specific local ports: `8545`
   → Next

7. **Select "Allow the connection"** → Next

8. **Check all three:**
   - Domain
   - Private
   - Public
   → Next

9. **Name:** `Ganache Blockchain`
   **Description:** `Allow Ganache blockchain on port 8545`
   → Finish

---

### Option 3: Command Line (Run PowerShell as Administrator)

```powershell
New-NetFirewallRule -DisplayName "Ganache Blockchain" -Direction Inbound -LocalPort 8545 -Protocol TCP -Action Allow
```

---

## ✅ How to Test If It Worked:

After adding the firewall rule, test from your phone:

1. **Hot restart your Flutter app** (press 'R' in terminal)
2. **Go to Blockchain Test screen**
3. **Click "Initialize Blockchain"**

**You should see:**
- ✅ Connected to Blockchain
- Your wallet address
- Balance
- Contract address

---

## 🔧 Alternative: Use ADB Port Forwarding (No Firewall Changes)

If you can't modify the firewall, use ADB to forward the port:

```powershell
# Forward port 8545 from computer to phone
adb -s 00196654V000209 reverse tcp:8545 tcp:8545
```

Then change the RPC URL back to:
```dart
static const String _rpcUrl = 'http://127.0.0.1:8545';
```

Hot restart the app, and it should work!

---

## 📊 Current Configuration:

```
Computer IP: 192.168.0.215
Ganache Port: 8545
Ganache Status: ✅ Running (listening on 0.0.0.0:8545)
Firewall: ❌ Blocking port 8545
Flutter RPC URL: http://192.168.0.215:8545
```

---

## 🎯 Choose Your Method:

**Easiest (but less secure):**
- Option 1: Temporarily disable firewall

**Best (secure):**
- Option 2 or 3: Add firewall rule

**Alternative (no firewall changes):**
- ADB port forwarding

---

Let me know which option you want to try, or if you need help with any of them! 🚀
