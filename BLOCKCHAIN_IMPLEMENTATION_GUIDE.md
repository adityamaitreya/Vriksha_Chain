# 🔗 Blockchain Implementation in VrikshaChain

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Smart Contract](#smart-contract)
4. [Flutter Integration](#flutter-integration)
5. [How It Works](#how-it-works)
6. [Data Flow](#data-flow)
7. [Security Features](#security-features)
8. [Testing](#testing)

---

## 🌟 Overview

VrikshaChain uses **Ethereum blockchain technology** to create an immutable, transparent, and secure supply chain tracking system for agricultural products. The blockchain integration ensures:

- ✅ **Tamper-proof records** - Once data is on blockchain, it cannot be altered
- ✅ **NFC authentication** - Verify product authenticity using NFC tags
- ✅ **Complete audit trail** - Track every step from harvest to delivery
- ✅ **Dual verification** - Cross-verify data between Firebase and Blockchain
- ✅ **Decentralized trust** - No single point of failure

---

## 🏗️ Architecture

### Technology Stack

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                    │
│  (Dart + web3dart library for blockchain interaction)   │
└─────────────────────┬───────────────────────────────────┘
                      │
         ┌────────────┴────────────┐
         │                         │
         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐
│   Firebase DB   │       │   Ethereum      │
│   (Real-time)   │       │   Blockchain    │
└─────────────────┘       └─────────────────┘
                                  │
                          ┌───────┴────────┐
                          │                │
                          ▼                ▼
                    ┌──────────┐    ┌──────────┐
                    │  Ganache │    │ Sepolia  │
                    │  (Local) │    │(Testnet) │
                    └──────────┘    └──────────┘
```

### Components

1. **Smart Contract** (Solidity)
   - File: `contracts/BatchTracking.sol`
   - Deployed on Ethereum blockchain
   - Stores immutable batch records

2. **Blockchain Service** (Dart)
   - File: `app/lib/services/blockchain_service.dart`
   - Connects Flutter app to blockchain
   - Manages wallet and transactions

3. **Firebase Service** (Dart)
   - File: `app/lib/services/firebase_service.dart`
   - Integrates blockchain with Firebase
   - Provides dual verification

4. **Smart Contract Deployment**
   - Truffle framework
   - Ganache (local blockchain)
   - Option to deploy to public testnets

---

## 📝 Smart Contract

### Location
```
contracts/BatchTracking.sol
```

### Key Features

#### 1. **Data Structures**

```solidity
struct Batch {
    string batchId;
    string productName;
    string variety;
    uint256 quantity;
    string unit;
    string location;
    uint256 harvestDate;
    uint256 expiryDate;
    string nfcTagId;          // NFC tag for authentication
    address creator;           // Wallet address of creator
    uint256 timestamp;         // Block timestamp
    bool exists;
}

struct NFCAuthentication {
    string authId;
    string batchId;
    string nfcTagId;
    uint256 timestamp;
    string location;
    bool isValid;              // True if NFC matches batch
}

struct QualityMetric {
    string metricId;
    string batchId;
    string metricType;         // e.g., "temperature", "pH"
    string value;
    string unit;
    uint256 timestamp;
    address inspector;
    bool exists;
}
```

#### 2. **Core Functions**

**a) Create Batch**
```solidity
function createBatch(
    string memory _batchId,
    string memory _productName,
    string memory _variety,
    uint256 _quantity,
    string memory _unit,
    string memory _location,
    uint256 _harvestDate,
    uint256 _expiryDate,
    string memory _nfcTagId
) public
```
- Creates immutable batch record on blockchain
- Links NFC tag to batch
- Records creator's wallet address
- Emits `BatchCreated` event

**b) Authenticate NFC Tag**
```solidity
function authenticateNFC(
    string memory _authId,
    string memory _batchId,
    string memory _nfcTagId,
    string memory _location
) public batchExists(_batchId) returns (bool)
```
- Verifies NFC tag matches stored tag
- Records authentication attempt
- Returns true/false for validity
- Emits `NFCAuthenticated` event

**c) Add Quality Metric**
```solidity
function addQualityMetric(
    string memory _metricId,
    string memory _batchId,
    string memory _metricType,
    string memory _value,
    string memory _unit
) public batchExists(_batchId)
```
- Adds quality check data
- Links to batch
- Records inspector's address
- Emits `QualityMetricAdded` event

#### 3. **Query Functions**

```solidity
// Get batch details
function getBatch(string memory _batchId) public view returns (...)

// Get all batch IDs
function getAllBatchIds() public view returns (string[] memory)

// Get quality metrics for a batch
function getBatchQualityMetrics(string memory _batchId) 
    public view returns (string[] memory)

// Get authentication history
function getBatchAuthentications(string memory _batchId) 
    public view returns (string[] memory)

// Get NFC authentication count
function getNFCAuthCount(string memory _nfcTagId) 
    public view returns (uint256)
```

---

## 📱 Flutter Integration

### 1. **Blockchain Service Setup**

File: `app/lib/services/blockchain_service.dart`

**Initialization**
```dart
class BlockchainService {
  // Connect to blockchain
  static const String _rpcUrl = 'http://192.168.0.215:8545';
  
  late Web3Client _client;
  late DeployedContract _contract;
  late EthPrivateKey _credentials;
  
  Future<void> initialize() async {
    // Initialize Web3 client
    _client = Web3Client(_rpcUrl, Client());
    
    // Load contract ABI
    final abiString = await rootBundle
        .loadString('assets/contracts/BatchTracking.json');
    
    // Get contract address
    final contractAddress = EthereumAddress.fromHex(
      '0x3380916E6b27100491c63c6f570627E60ff3cd53'
    );
    
    // Create contract instance
    _contract = DeployedContract(
      ContractAbi.fromJson(abiJson['abi'], 'BatchTracking'),
      contractAddress,
    );
    
    // Load wallet credentials
    await _loadOrCreateCredentials();
  }
}
```

### 2. **Creating a Batch on Blockchain**

```dart
Future<String> createBatch({
  required String batchId,
  required String productName,
  required String nfcTagId,
  // ... other parameters
}) async {
  // Get contract function
  final function = _contract.function('createBatch');
  
  // Create transaction
  final transaction = Transaction.callContract(
    contract: _contract,
    function: function,
    parameters: [
      batchId,
      productName,
      variety,
      BigInt.from(quantity),
      unit,
      location,
      BigInt.from(harvestDate.millisecondsSinceEpoch ~/ 1000),
      BigInt.from(expiryDate.millisecondsSinceEpoch ~/ 1000),
      nfcTagId,
    ],
    maxGas: 3000000,
  );
  
  // Send transaction
  final txHash = await _client.sendTransaction(
    _credentials,
    transaction,
    chainId: 1337,
  );
  
  // Wait for confirmation
  await _waitForTransaction(txHash);
  
  return txHash; // Transaction hash
}
```

### 3. **Dual Verification (Firebase + Blockchain)**

File: `app/lib/services/firebase_service.dart`

```dart
Future<Map<String, dynamic>> createBatchWithBlockchain({
  required String batchId,
  required Map<String, dynamic> batchData,
}) async {
  try {
    // 1. Create on blockchain first (immutable)
    final txHash = await _blockchain.createBatch(
      batchId: batchId,
      productName: batchData['productName'],
      nfcTagId: batchData['nfcTagId'],
      // ... other fields
    );
    
    // 2. Add blockchain reference to Firebase data
    final blockchainData = {
      ...batchData,
      'blockchainTxHash': txHash,
      'blockchainVerified': true,
      'blockchainTimestamp': DateTime.now().toIso8601String(),
    };
    
    // 3. Save to Firebase
    await batchRef(batchId).set(blockchainData);
    
    return {
      'success': true,
      'txHash': txHash,
      'batchId': batchId,
    };
  } catch (e) {
    // Fallback: Save to Firebase only if blockchain fails
    await batchRef(batchId).set({
      ...batchData,
      'blockchainVerified': false,
      'blockchainError': e.toString(),
    });
    
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}
```

### 4. **NFC Authentication**

```dart
Future<Map<String, dynamic>> authenticateNFCWithBlockchain({
  required String authId,
  required String batchId,
  required String nfcTagId,
  required String location,
}) async {
  // 1. Verify on blockchain
  final blockchainResult = await _blockchain.authenticateNFC(
    authId: authId,
    batchId: batchId,
    nfcTagId: nfcTagId,
    location: location,
  );
  
  // 2. Check Firebase
  final batchSnapshot = await batchRef(batchId).get();
  final storedNfcId = batchSnapshot.value['nfcTagId'];
  final isFirebaseValid = storedNfcId == nfcTagId;
  
  // 3. Cross-verify both sources
  final isBothValid = isFirebaseValid && 
                      blockchainResult['isValid'];
  
  // 4. Save authentication record
  await nfcAuthenticationRef(authId).set({
    'authId': authId,
    'batchId': batchId,
    'nfcTagId': nfcTagId,
    'isValid': isBothValid,
    'firebaseValid': isFirebaseValid,
    'blockchainValid': blockchainResult['isValid'],
    'blockchainTxHash': blockchainResult['txHash'],
    'verificationType': 'dual',
    'timestamp': DateTime.now().toIso8601String(),
  });
  
  return {
    'success': true,
    'isValid': isBothValid,
    'message': isBothValid 
        ? 'NFC tag verified on both Firebase and Blockchain' 
        : 'NFC tag verification failed',
  };
}
```

---

## 🔄 How It Works

### Workflow: Creating a Batch

```
User Action: Create New Batch
        ↓
1. Flutter App (UI)
        ↓
2. Firebase Service
        ↓
   ┌────┴────┐
   ↓         ↓
3. Blockchain Service    4. Firebase Database
   (creates immutable       (stores with
    record on chain)        blockchain txHash)
        ↓                        ↓
5. Returns TX Hash        6. Batch visible in app
        ↓
7. User can verify on blockchain explorer
```

### Workflow: NFC Authentication

```
User Action: Scan NFC Tag
        ↓
1. NFC Service reads tag ID
        ↓
2. Firebase Service
        ↓
   ┌────┴─────┐
   ↓          ↓
3. Query Firebase    4. Query Blockchain
   (get stored NFC)     (authenticateNFC)
        ↓                    ↓
5. Compare results
        ↓
   ┌────┴────┐
   ↓         ↓
Valid?    Invalid?
   ↓         ↓
6. ✅ Show     ❌ Show
   Success     Error
        ↓
7. Record authentication attempt
   (on both Firebase & Blockchain)
```

---

## 📊 Data Flow

### Example: Batch Journey

1. **Harvest** (Day 1)
   ```
   Farmer creates batch:
   - Scans NFC tag
   - Enters: product, quantity, location
   - App creates batch on blockchain
   - Blockchain returns TX: 0xabc123...
   - Firebase stores batch with TX hash
   ```

2. **Quality Check** (Day 2)
   ```
   Inspector adds quality metric:
   - Checks temperature, pH
   - App calls addQualityMetric() on blockchain
   - Blockchain links metric to batch
   - Metric cannot be altered
   ```

3. **Distribution** (Day 3)
   ```
   Distributor scans NFC:
   - App reads NFC tag
   - Calls authenticateNFC() on blockchain
   - Blockchain verifies tag matches batch
   - Returns: Valid ✅
   - Records authentication event
   ```

4. **Consumer** (Day 5)
   ```
   End user verifies product:
   - Scans NFC tag
   - App shows:
     * Product details from blockchain
     * Full timeline (harvest → delivery)
     * All quality checks
     * Authentication history
   - Consumer sees complete, tamper-proof history
   ```

---

## 🔒 Security Features

### 1. **Immutability**
- Once data is on blockchain, it **cannot be changed**
- All modifications are transparent and traceable
- Creates permanent audit trail

### 2. **Cryptographic Verification**
```solidity
// NFC authentication uses keccak256 hash comparison
bool isValid = keccak256(abi.encodePacked(batches[_batchId].nfcTagId)) == 
               keccak256(abi.encodePacked(_nfcTagId));
```

### 3. **Wallet Authentication**
- Each transaction signed with private key
- Creator's wallet address recorded on-chain
- Proof of who created/modified data

### 4. **Event Logging**
```solidity
event BatchCreated(
    string indexed batchId,
    string productName,
    address indexed creator,
    uint256 timestamp
);

event NFCAuthenticated(
    string indexed authId,
    string indexed batchId,
    string nfcTagId,
    bool isValid,
    uint256 timestamp
);
```
- All actions emit events
- Events stored permanently on blockchain
- Can be queried for complete history

### 5. **Access Control**
```solidity
modifier batchExists(string memory batchId) {
    require(batches[batchId].exists, "Batch does not exist");
    _;
}

modifier onlyBatchCreator(string memory batchId) {
    require(
        batches[batchId].creator == msg.sender,
        "Only batch creator can perform this action"
    );
    _;
}
```

### 6. **Dual Verification**
- Data stored on both Firebase (fast reads) and Blockchain (immutable)
- App cross-verifies critical data
- Detects tampering attempts

---

## 🧪 Testing

### Local Testing with Ganache

1. **Start Ganache**
   ```bash
   ganache --host 0.0.0.0 --port 8545
   ```

2. **Deploy Contract**
   ```bash
   truffle compile
   truffle migrate
   ```

3. **Run Flutter App**
   ```bash
   cd app
   flutter run
   ```

4. **Test in App**
   - Navigate to "Blockchain Test" screen
   - Click "Initialize Blockchain"
   - Click "Create Test Batch"
   - Click "Test NFC Authentication"

### Test Results to Verify

✅ **Connection Test**
```
✅ Connected to Blockchain
Wallet: 0x4a46bcaa00bdbf3727208fae187f783e77882f90
Balance: 1000 ETH
Contract: 0x3380916E6b27100491c63c6f570627E60ff3cd53
```

✅ **Batch Creation**
```
✅ Batch Created!
Batch ID: TEST_1699999999
TX Hash: 0xabcd1234...
Blockchain Verified: true
```

✅ **NFC Authentication**
```
✅ NFC Authenticated
Valid: true
Firebase: ✅
Blockchain: ✅
TX Hash: 0xef567890...
```

---

## 📈 Benefits of Blockchain Integration

### For Farmers
- ✅ Proof of origin
- ✅ Cannot be counterfeited
- ✅ Transparent pricing history

### For Distributors
- ✅ Verify product authenticity instantly
- ✅ Track entire supply chain
- ✅ Quality assurance records

### For Consumers
- ✅ Complete product history
- ✅ Verify authenticity by scanning NFC
- ✅ See all quality checks
- ✅ Know exact origin and journey

### For Business
- ✅ Reduced fraud
- ✅ Improved traceability
- ✅ Regulatory compliance
- ✅ Enhanced brand trust
- ✅ Automated record-keeping

---

## 🔗 Key Blockchain Concepts Used

### 1. **Smart Contracts**
Self-executing code on blockchain that runs exactly as programmed

### 2. **Transactions**
Actions that modify blockchain state (e.g., creating a batch)

### 3. **Gas**
Fee paid to execute transactions (paid in ETH)

### 4. **Wallet**
Account with private key that signs transactions

### 5. **Events**
Logs emitted by smart contracts for off-chain tracking

### 6. **ABI (Application Binary Interface)**
JSON specification of contract functions and events

---

## 🚀 Deployment Options

### Option 1: Local (Development)
- **Ganache** - Local blockchain simulator
- **Pros**: Free, fast, easy testing
- **Cons**: Only accessible locally

### Option 2: Testnet (Staging)
- **Sepolia Testnet** - Public Ethereum test network
- **Pros**: Free test ETH, public access
- **Cons**: Slower than local

### Option 3: Mainnet (Production)
- **Ethereum Mainnet** - Real Ethereum network
- **Pros**: Real value, maximum security
- **Cons**: Costs real ETH

---

## 📚 Resources

### Documentation
- **Solidity**: https://docs.soliditylang.org/
- **web3dart**: https://pub.dev/packages/web3dart
- **Truffle**: https://trufflesuite.com/docs/
- **Ganache**: https://trufflesuite.com/ganache/

### Tools Used
- **Flutter** - Mobile app framework
- **Solidity** - Smart contract language
- **Truffle** - Development framework
- **Ganache** - Local blockchain
- **web3dart** - Ethereum library for Dart

### Project Files
- Smart Contract: `contracts/BatchTracking.sol`
- Blockchain Service: `app/lib/services/blockchain_service.dart`
- Firebase Integration: `app/lib/services/firebase_service.dart`
- Test Screen: `app/lib/screens/blockchain_test_screen.dart`

---

## 🎯 Summary

VrikshaChain uses blockchain to create a **trustless, transparent, and tamper-proof** supply chain system:

1. **Every batch** is recorded on blockchain with NFC tag
2. **Quality checks** are permanently stored on-chain
3. **NFC authentication** verifies product authenticity
4. **Complete history** is available to all stakeholders
5. **Dual verification** ensures data integrity
6. **No single point of failure** - decentralized architecture

This implementation combines the **speed of Firebase** for real-time access with the **immutability of blockchain** for trust and security.

---

**For questions or contributions, contact the VrikshaChain team.**
