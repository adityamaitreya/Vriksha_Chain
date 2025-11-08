# 🔥 Firewall Issue - Quick Fix

## Problem:
ADB port forwarding isn't working. We need to allow Ganache through Windows Firewall.

## ✅ The Fix (Choose One):

### Option 1: Run PowerShell Script (Easiest)

1. **Right-click on PowerShell** and select **"Run as Administrator"**
2. Run this command:
   ```powershell
   cd C:\Users\BYTE\Desktop\Main
   .\add-firewall-rule.ps1
   ```
3. Press any key when done
4. **Press 'R'** in Flutter terminal to hot restart

---

### Option 2: Manual Firewall Rule

1. **Press Windows + I** → Open Settings
2. Go to **Privacy & Security** → **Windows Security**
3. Click **Firewall & network protection**
4. Click **Advanced settings**
5. Click **Inbound Rules** (left side)
6. Click **New Rule...** (right side)
7. Select **Port** → Next
8. Select **TCP**, enter `8545` → Next
9. Select **Allow the connection** → Next
10. Check all three: Domain, Private, Public → Next
11. Name: `Ganache Blockchain` → Finish

Then **press 'R'** in Flutter terminal

---

### Option 3: Temporary (Turn Off Firewall)

**⚠️ Only for testing - remember to turn it back on!**

1. **Press Windows + I** → Settings
2. Go to **Privacy & Security** → **Windows Security**
3. Click **Firewall & network protection**
4. Click **Private network** (active network)
5. Turn **OFF** Microsoft Defender Firewall
6. **Press 'R'** in Flutter terminal to hot restart
7. Test your app
8. **Turn firewall back ON** when done

---

## Current Status:

✅ **Ganache is running:** `0.0.0.0:8545`
✅ **Network accessible:** `192.168.0.215:8545`
✅ **Contract deployed:** `0x3380916E6b27100491c63c6f570627E60ff3cd53`
✅ **RPC URL updated:** `http://192.168.0.215:8545`
❌ **Firewall:** Blocking port 8545

---

## After Adding Firewall Rule:

**Press 'R'** in the Flutter terminal (not 'r', capital 'R')

Then go to your app and:
1. Navigate to **Blockchain Test** screen
2. Click **"Initialize Blockchain"**

You should see:
```
✅ Connected to Blockchain
Wallet: 0x4a46bcaa00bdbf3727208fae187f783e77882f90
Balance: 1000 ETH
Contract: 0x3380916E6b27100491c63c6f570627E60ff3cd53
```

---

## 🚀 Choose your preferred option and let me know when you're ready!
