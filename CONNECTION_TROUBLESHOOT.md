# 🔍 Connection Failed - Troubleshooting

## ✅ What's Working:
- ✅ Ganache is running (localhost:8545)
- ✅ ADB device connected (192.168.0.215:5555)
- ✅ ADB port forwarding active (tcp:8545 → tcp:8545)

## ❌ Issue:
Flutter app cannot connect to blockchain

---

## 🔧 Quick Fixes to Try:

### Fix 1: Clear App Cache & Hot Restart

The app might have cached the old connection. In the Flutter terminal, press:

```
R
```

(Capital R for full hot restart)

---

### Fix 2: Force Stop and Relaunch App

1. Close the app on your phone completely
2. In the terminal, press `q` to quit
3. Run again:
   ```powershell
   flutter run -d 192.168.0.215:5555
   ```

---

### Fix 3: Check Contract ABI File

Make sure the contract ABI exists:

```powershell
Test-Path "C:\Users\BYTE\Desktop\Main\app\assets\contracts\BatchTracking.json"
```

Should return `True`

---

### Fix 4: Test Raw Connection from Phone

Let's verify the phone can actually reach Ganache through ADB:

#### Option A: Use curl (if available on your phone)
From a terminal emulator app on your phone:
```bash
curl http://127.0.0.1:8545
```

#### Option B: Use ADB shell
From PowerShell:
```powershell
adb -s 192.168.0.215:5555 shell curl http://127.0.0.1:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

Should return something like: `{"jsonrpc":"2.0","id":1,"result":"0x0"}`

---

### Fix 5: Check App Logs

Look at the Flutter console output. What's the exact error message?

Common errors:
- **"Connection refused"** → ADB port forwarding not working
- **"Connection timeout"** → Ganache not running or wrong URL
- **"Contract not found"** → Wrong contract address
- **"Cannot load asset"** → ABI file missing

---

### Fix 6: Verify Configuration

Check the blockchain service settings:

```powershell
Get-Content "C:\Users\BYTE\Desktop\Main\app\lib\services\blockchain_service.dart" | Select-String -Pattern "rpcUrl"
```

Should show: `http://127.0.0.1:8545`

---

### Fix 7: Re-establish Everything

Let's reset everything from scratch:

```powershell
# 1. Stop Ganache
Get-Job | Stop-Job
Get-Job | Remove-Job

# 2. Start Ganache fresh
Start-Job -ScriptBlock { Set-Location "C:\Users\BYTE\Desktop\Main"; npx ganache --host 0.0.0.0 --port 8545 }
Start-Sleep -Seconds 8

# 3. Reset ADB port forwarding
adb -s 192.168.0.215:5555 reverse --remove-all
adb -s 192.168.0.215:5555 reverse tcp:8545 tcp:8545

# 4. Verify
Test-NetConnection -ComputerName 127.0.0.1 -Port 8545
adb -s 192.168.0.215:5555 reverse --list
```

Then hot restart the app (press `R`)

---

## 📋 Information I Need:

To help you better, please tell me:

1. **What's the exact error message?**
   - Look at the Flutter console output
   - What does it say after you click "Initialize Blockchain"?

2. **Screenshot of the app screen**
   - What do you see on the Blockchain Test screen?

3. **Does the app show any error dialogs?**

4. **Run this command and send output:**
   ```powershell
   adb -s 192.168.0.215:5555 shell curl http://127.0.0.1:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
   ```

---

## 🎯 Most Likely Issues:

### Issue 1: App Not Updated
**Solution:** Press `R` in Flutter terminal (not just `r`, needs capital `R`)

### Issue 2: ADB Forward Disconnected
**Solution:**
```powershell
adb -s 192.168.0.215:5555 reverse tcp:8545 tcp:8545
```

### Issue 3: Ganache Stopped
**Solution:**
```powershell
Get-Job | Stop-Job
Start-Job -ScriptBlock { Set-Location "C:\Users\BYTE\Desktop\Main"; npx ganache --host 0.0.0.0 --port 8545 }
```

### Issue 4: Contract ABI Missing
**Solution:**
```powershell
xcopy /Y C:\Users\BYTE\Desktop\Main\build\contracts\BatchTracking.json C:\Users\BYTE\Desktop\Main\app\assets\contracts\
```

---

## 🚀 Quick Recovery Steps:

**Run these commands in order:**

```powershell
# 1. Verify Ganache
Test-NetConnection -ComputerName 127.0.0.1 -Port 8545

# 2. Verify ADB forward
adb -s 192.168.0.215:5555 reverse --list

# 3. If not listed, add it
adb -s 192.168.0.215:5555 reverse tcp:8545 tcp:8545

# 4. Test connection
adb -s 192.168.0.215:5555 shell curl http://127.0.0.1:8545 -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}'
```

Then **press `R`** in your Flutter terminal to hot restart.

---

## 💡 Alternative Solution: Use Emulator

If physical device continues to have issues, try using an Android emulator instead:

```powershell
# Start emulator
flutter emulators --launch <emulator_name>

# Run app on emulator
flutter run -d emulator-5554
```

Emulators work better with the default `10.0.2.2:8545` configuration.

---

**Tell me what error you're seeing and I'll help you fix it! 🔧**
