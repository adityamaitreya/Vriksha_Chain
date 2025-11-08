# Blockchain Integration Setup Guide

## What You Need to Provide

### 1. **System Requirements**
- Node.js (v16 or higher)
- npm or yarn
- Ganache (for local blockchain)
- Truffle (for smart contract deployment)

### 2. **For Testing**
- A computer/laptop to run Ganache
- Flutter device (Android/iOS) on same network as computer
- Or use Android Emulator

---

## Step-by-Step Setup

### Phase 1: Install Dependencies

#### 1.1 Install Node.js Dependencies
```bash
cd C:\Users\BYTE\Desktop\Main
npm install
```

#### 1.2 Install Flutter Dependencies
```bash
cd C:\Users\BYTE\Desktop\Main\app
flutter pub get
```

#### 1.3 Install Blockchain Tools
```bash
# Install Truffle globally
npm install -g truffle

# Install Ganache CLI globally
npm install -g ganache
```

---

### Phase 2: Setup Local Blockchain

#### 2.1 Start Ganache
Open a new terminal and run:
```bash
ganache --host 0.0.0.0 --port 8545
```

**Important**: Keep this terminal open! This is your blockchain.

You should see output like:
```
Ganache CLI v6.12.2
Available Accounts
==================
(0) 0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb (100 ETH)
(1) 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f (100 ETH)
...

Private Keys
==================
(0) 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
(1) 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
...

Listening on 0.0.0.0:8545
```

#### 2.2 Get Your Computer's IP Address

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address" (example: 192.168.1.100)

**Mac/Linux:**
```bash
ifconfig | grep inet
```

**Save this IP address - you'll need it!**

---

### Phase 3: Deploy Smart Contract

#### 3.1 Compile Contract
```bash
cd C:\Users\BYTE\Desktop\Main
truffle compile
```

You should see:
```
Compiling your contracts...
===========================
> Compiling .\contracts\BatchTracking.sol
> Artifacts written to C:\Users\BYTE\Desktop\Main\build\contracts
> Compiled successfully using:
   - solc: 0.8.0
```

#### 3.2 Deploy Contract
```bash
truffle migrate
```

**VERY IMPORTANT**: Save the output! You'll see something like:
```
Deploying 'BatchTracking'
-------------------------
> transaction hash:    0x1234...
> Blocks: 0            Seconds: 0
> contract address:    0x5FbDB2315678afecb367f032d93F642f64180aa3
> block number:        1
> block timestamp:     1699999999
> account:             0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb
> balance:             99.99
> gas used:            2500000
> gas price:           20 gwei
> value sent:          0 ETH
> total cost:          0.05 ETH

✅ BatchTracking deployed at: 0x5FbDB2315678afecb367f032d93F642f64180aa3
```

**Copy the contract address: `0x5FbDB2315678afecb367f032d93F642f64180aa3`**

---

### Phase 4: Setup Flutter App

#### 4.1 Create Contracts Folder
```bash
cd C:\Users\BYTE\Desktop\Main\app
mkdir assets
mkdir assets\contracts
```

#### 4.2 Copy Contract ABI
```bash
copy ..\build\contracts\BatchTracking.json assets\contracts\
```

#### 4.3 Update blockchain_service.dart

Edit `app/lib/services/blockchain_service.dart`

Change line 15:
```dart
static const String _rpcUrl = 'http://YOUR_COMPUTER_IP:8545';
```

Replace `YOUR_COMPUTER_IP` with your IP address from Step 2.2

Examples:
- Android Emulator: `http://10.0.2.2:8545`
- Physical Android Device: `http://192.168.1.100:8545` (your actual IP)
- iOS Simulator: `http://127.0.0.1:8545`

---

### Phase 5: Run Flutter App

#### 5.1 Clean and Build
```bash
cd C:\Users\BYTE\Desktop\Main\app
flutter clean
flutter pub get
flutter run
```

#### 5.2 Navigate to Test Screen

In your Flutter app:
1. Login
2. Go to Dashboard
3. Add a temporary navigation button or route to `BlockchainTestScreen`

**Or add this to your router:**

Edit `app/lib/routes/app_router.dart` and add:
```dart
GoRoute(
  path: '/blockchain-test',
  builder: (context, state) => const BlockchainTestScreen(),
),
```

---

### Phase 6: Testing

#### 6.1 Initialize Blockchain

1. Open the Blockchain Test Screen in your app
2. Paste the contract address from Step 3.2
3. Click "Save Contract Address"
4. Click "Initialize Blockchain"

**Expected Result:**
- ✅ Connected to blockchain
- Wallet address displayed
- Balance shown (should be 0 ETH initially)

**If you see an error:**
- Check Ganache is running
- Verify the IP address in `blockchain_service.dart`
- Make sure your device and computer are on same network

#### 6.2 Fund Your Wallet (Optional)

If you want to test with actual funds:

1. Get your wallet address from the app
2. In a terminal, send ETH from Ganache:

```bash
# Open Truffle console
truffle console

# Send 10 ETH to your wallet
web3.eth.sendTransaction({
  from: "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb", // First Ganache account
  to: "YOUR_WALLET_ADDRESS_FROM_APP",
  value: web3.utils.toWei("10", "ether")
})

// Exit
.exit
```

#### 6.3 Create Test Batch

1. Click "Create Test Batch"
2. Wait for transaction to complete (5-10 seconds)

**Expected Result:**
- ✅ Batch created!
- Transaction hash displayed
- Total batches count increases

#### 6.4 Test NFC Authentication

1. Click "Test NFC Authentication"
2. Wait for transaction

**Expected Result:**
- ✅ NFC Authentication
- Valid: true
- Firebase: true
- Blockchain: true
- Transaction hash displayed

---

### Phase 7: Setup Web App

#### 7.1 Install Web Dependencies
```bash
cd C:\Users\BYTE\Desktop\Main
npm install ethers web3
```

#### 7.2 Copy Contract ABI
```bash
mkdir src\contracts
copy build\contracts\BatchTracking.json src\contracts\
```

#### 7.3 Create Test Component

Create `src/components/BlockchainTest.tsx`:

```typescript
import { useState } from 'react';
import BlockchainService from '../services/blockchainService';
import { Button } from './ui/button';
import { Card } from './ui/card';
import { Input } from './ui/input';

export default function BlockchainTest() {
  const [status, setStatus] = useState('Not initialized');
  const [contractAddress, setContractAddress] = useState('');
  const [walletAddress, setWalletAddress] = useState('');
  const [balance, setBalance] = useState('');
  const [loading, setLoading] = useState(false);

  const blockchain = BlockchainService.getInstance();

  const initialize = async () => {
    setLoading(true);
    try {
      await blockchain.initialize(contractAddress);
      setWalletAddress(blockchain.getWalletAddress());
      setBalance(await blockchain.getBalance());
      setStatus('✅ Connected to blockchain');
    } catch (error) {
      setStatus(`❌ Error: ${error}`);
    }
    setLoading(false);
  };

  const createTestBatch = async () => {
    setLoading(true);
    try {
      const batchId = `TEST_${Date.now()}`;
      const txHash = await blockchain.createBatch(
        batchId,
        'Test Tomatoes',
        'Cherry',
        100,
        'kg',
        'Test Farm',
        new Date(),
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        `NFC_${Date.now()}`
      );
      setStatus(`✅ Batch created! TX: ${txHash}`);
    } catch (error) {
      setStatus(`❌ Error: ${error}`);
    }
    setLoading(false);
  };

  return (
    <Card className="p-6">
      <h2 className="text-2xl font-bold mb-4">Blockchain Testing</h2>
      
      <div className="space-y-4">
        <div>
          <label className="block mb-2">Contract Address</label>
          <Input
            value={contractAddress}
            onChange={(e) => setContractAddress(e.target.value)}
            placeholder="0x..."
          />
        </div>

        <Button onClick={initialize} disabled={loading}>
          Initialize Blockchain
        </Button>

        <div className="p-4 bg-gray-100 rounded">
          <p>{status}</p>
          {walletAddress && <p>Wallet: {walletAddress}</p>}
          {balance && <p>Balance: {balance} ETH</p>}
        </div>

        <Button onClick={createTestBatch} disabled={loading || !walletAddress}>
          Create Test Batch
        </Button>
      </div>
    </Card>
  );
}
```

#### 7.4 Run Web App
```bash
npm run dev
```

Open http://localhost:5173 and add the test component to a page.

---

## Troubleshooting

### Problem: "Cannot connect to blockchain"
**Solution:**
- Check Ganache is running
- Verify IP address is correct
- Check firewall allows port 8545

### Problem: "Contract not initialized"
**Solution:**
- Make sure you deployed the contract
- Verify contract address is correct
- Check ABI file is in assets/contracts/

### Problem: "Insufficient funds"
**Solution:**
- Your wallet needs ETH for gas
- Use the funding command from Step 6.2
- Or use a Ganache account directly

### Problem: "Transaction timeout"
**Solution:**
- Check Ganache is responding
- Try increasing gas limit
- Restart Ganache

---

## Production Deployment

### For Testnet (Sepolia):

1. Get Sepolia ETH from faucet: https://sepoliafaucet.com/
2. Create Infura account: https://infura.io/
3. Update RPC URL to: `https://sepolia.infura.io/v3/YOUR_PROJECT_ID`
4. Update chain ID to: `11155111`
5. Deploy with: `truffle migrate --network sepolia`

---

## What I Need From You

To complete the setup, please provide:

1. **Confirmation that you installed:**
   - Node.js
   - Ganache
   - Truffle

2. **Your computer's IP address** (from Step 2.2)

3. **Contract address after deployment** (from Step 3.2)

4. **Any error messages** you encounter during setup

5. **Screenshot** of Ganache running

6. **Test results** from the Flutter app

Once you provide these, I can help you:
- Configure the correct IP addresses
- Debug any connection issues
- Deploy to testnet
- Integrate with existing batch creation flow
- Add blockchain verification to all NFC scans
