# ✅ Network Configuration Updated!

## What I Changed:

**File:** `app/lib/services/blockchain_service.dart`
**Line 14:** Updated RPC URL to your computer's IP

```dart
static const String _rpcUrl = 'http://192.168.0.215:8545';
```

---

## 🔄 How to Apply the Changes:

### Option 1: Hot Restart (Faster)
In the terminal where Flutter is running, press **'R'** (capital R) for hot restart

### Option 2: Save and Hot Reload
Just save the file (`Ctrl+S`) and the app will automatically reload

---

## 📱 What to Do in the App:

### Step 1: Go to Blockchain Test Screen
- On your phone's Dashboard
- Scroll down
- Click the blue **"Blockchain Test"** button

### Step 2: You'll See:
- Contract Address field (pre-filled): `0x3380916E6b27100491c63c6f570627E60ff3cd53`
- Your wallet address
- Initialize button

### Step 3: Initialize Blockchain
1. Click **"Save Contract Address"** (if not already saved)
2. Click **"Initialize Blockchain"**

**Expected Result:**
```
✅ Connected to Blockchain
Network: http://192.168.0.215:8545
Wallet: 0x4a46bcaa00bdbf3727208fae187f783e77882f90
Balance: 0 ETH (will update after connection)
Contract: 0x3380916E6b27100491c63c6f570627E60ff3cd53
Total Batches: 0
```

### Step 4: Create Test Batch
1. Click **"Create Test Batch"** button
2. Wait 5-10 seconds
3. You should see:
   - ✅ Success message
   - Transaction hash (0x...)
   - Batch ID (TEST_[timestamp])

### Step 5: Test NFC Authentication
1. Click **"Test NFC Authentication"** button
2. Wait 5-10 seconds
3. You should see:
   - ✅ Valid: true
   - Firebase Check: ✅
   - Blockchain Check: ✅
   - Transaction hash

---

## ⚠️ If Connection Fails:

### Check 1: Is Ganache Running?
```powershell
Test-NetConnection -ComputerName 192.168.0.215 -Port 8545
```

Should show: `TcpTestSucceeded : True`

### Check 2: Restart Ganache with Your IP
```powershell
Get-Job | Stop-Job; Get-Job | Remove-Job
Start-Job -ScriptBlock { Set-Location "C:\Users\BYTE\Desktop\Main"; npx ganache --host 0.0.0.0 --port 8545 }
```

### Check 3: Check Windows Firewall
Windows Firewall might be blocking connections. Try:

**Option A:** Temporarily disable firewall (for testing)
- Windows Security → Firewall & network protection
- Turn off for Private network

**Option B:** Add rule manually
- Windows Security → Firewall & network protection
- Advanced settings → Inbound Rules → New Rule
- Port → TCP → 8545 → Allow

### Check 4: Same WiFi Network?
Make sure your phone and computer are on the **same WiFi network**!

---

## 🎯 Testing Checklist

Once connected, test these:

- [ ] Initialize blockchain (see connection status)
- [ ] View wallet address and balance
- [ ] Create test batch (verify transaction hash)
- [ ] Authenticate NFC (dual verification passes)
- [ ] Check Firebase has the data
- [ ] Verify blockchain has the data

---

## 📊 What's Happening Behind the Scenes:

1. **Your Phone** (192.168.0.X) → connects to → **Your Computer** (192.168.0.215:8545)
2. **Your Computer** runs Ganache blockchain
3. Flutter app sends transactions to Ganache
4. Ganache processes and returns results
5. App displays transaction hashes and data

---

## 🚀 Network Configuration Summary:

```
Device Type: Physical Android (A001)
Computer IP: 192.168.0.215
Blockchain Port: 8545
RPC URL: http://192.168.0.215:8545
Contract Address: 0x3380916E6b27100491c63c6f570627E60ff3cd53
Wallet Address: 0x4a46bcaa00bdbf3727208fae187f783e77882f90
```

---

## 📝 Next Steps After Successful Test:

Once you confirm everything works:

1. ✅ Integrate into production batch creation
2. ✅ Add blockchain verification to NFC scanning
3. ✅ Create consumer verification page
4. ✅ Add transaction history view
5. ✅ Deploy to Ethereum testnet (Sepolia)

---

## 💡 Quick Commands:

**Test Connection:**
```powershell
Test-NetConnection -ComputerName 192.168.0.215 -Port 8545
```

**Check Ganache Status:**
```powershell
Get-Job
```

**Restart Ganache:**
```powershell
Get-Job | Stop-Job
Start-Job -ScriptBlock { Set-Location "C:\Users\BYTE\Desktop\Main"; npx ganache --host 0.0.0.0 --port 8545 }
```

**View Ganache Logs:**
```powershell
Get-Job | Receive-Job
```

---

**Now hot restart your app (press 'R') and try the blockchain test! 🚀**

Let me know what happens when you click "Initialize Blockchain"!
