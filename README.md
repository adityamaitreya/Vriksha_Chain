# Vriksha_Chain
VrikshaChain is a blockchain-powered supply chain platform for agricultural and herbal products. It uses Ethereum smart contracts, Firebase, NFC/QR authentication, and Flutter + React apps to provide end-to-end traceability, tamper-proof batch records, real-time sync, and easy public verification without crypto knowledge.

#### [Web_Link](https://vriksha-chain.web.app/)
#### [APK_Link](https://drive.google.com/file/d/1kcqHzCqv5-D2LRwWCQ4_Zx0AEs2_ZWIq/view?usp=sharing)

# 🌿 VrikshaChain - Blockchain-Powered Herbal Supply Chain Management

<div align="center">

![VrikshaChain Logo](https://img.shields.io/badge/VrikshaChain-Agricultural%20Blockchain-4CAF50?style=for-the-badge&logo=leaf&logoColor=white)

**Transparent • Secure • Immutable**

[![React](https://img.shields.io/badge/React-18.3-61DAFB?style=flat&logo=react&logoColor=white)](https://reactjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?style=flat&logo=flutter&logoColor=white)](https://flutter.dev/)
[![Solidity](https://img.shields.io/badge/Solidity-0.8-363636?style=flat&logo=solidity&logoColor=white)](https://soliditylang.org/)
[![Firebase](https://img.shields.io/badge/Firebase-12.4-FFCA28?style=flat&logo=firebase&logoColor=white)](https://firebase.google.com/)
[![Ethereum](https://img.shields.io/badge/Ethereum-Web3-3C3C3D?style=flat&logo=ethereum&logoColor=white)](https://ethereum.org/)

[Features](#-key-features) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [Architecture](#-system-architecture) • [Demo](#-demo)

</div>

---

## 📋 Overview

**VrikshaChain** is a comprehensive blockchain-integrated supply chain management platform specifically designed for the herbal and agricultural product industry. The platform combines **Web3 technology**, **Firebase real-time database**, **NFC authentication**, and **cross-platform mobile/web applications** to create a transparent, tamper-proof, and verifiable supply chain tracking system from farm to consumer.

### 🎯 Problem Statement

Traditional agricultural supply chains face critical challenges:

- **❌ Lack of transparency** - Consumers cannot verify product authenticity or origin
- **❌ Data manipulation** - Records can be altered or falsified without detection
- **❌ Counterfeit products** - No reliable method to authenticate genuine products
- **❌ Trust issues** - Multiple stakeholders with conflicting interests
- **❌ Poor traceability** - Difficult to track products from farm to consumer
- **❌ Quality verification** - No immutable record of quality inspections

### ✅ Our Solution

VrikshaChain provides a **hybrid blockchain + cloud architecture** that delivers:

1. **🔒 Blockchain Immutability** - All critical data stored on Ethereum blockchain (tamper-proof)
2. **📱 NFC Tag Authentication** - Physical products linked to blockchain records via NFC tags
3. **✅ Dual Verification System** - Data cross-verified between Firebase (fast) and Blockchain (secure)
4. **🔄 Real-time Synchronization** - Instant updates across web and mobile platforms
5. **👥 Multi-stakeholder Access** - Farmers, inspectors, distributors, and consumers share one platform
6. **📲 QR Code Public Access** - Anyone can verify product authenticity by scanning QR codes

---

## 🚀 Key Features

### **1. Blockchain-Verified Batch Tracking**
- Immutable batch records stored on Ethereum blockchain
- Complete product information: name, quantity, harvest date, location, NFC tag ID
- Transaction hash as permanent proof of authenticity
- Tamper-proof audit trail for regulatory compliance

### **2. NFC Tag Authentication**
- Physical NFC tags linked to blockchain records
- Instant product verification through NFC scanning
- Anti-counterfeiting protection at the product level
- Mobile app reads and validates tags in real-time

### **3. Quality Metrics Management**
- Record quality inspections on blockchain
- Track temperature, pH, moisture, and custom metrics
- Inspector identity and timestamp permanently recorded
- Historical quality data for compliance and analytics

### **4. Multi-Platform Access**

#### **📱 Mobile App (Flutter)**
- **Android & iOS support** with native performance
- **Offline-first architecture** for field use
- **NFC tag reading** and authentication
- **QR code generation** for batch sharing
- **Real-time sync** with Firebase and blockchain
- **Camera integration** for scanning and documentation

#### **💻 Web App (React + TypeScript)**
- **Responsive dashboard** with analytics and charts
- **Batch management** interface for creating and tracking
- **Public verification pages** for consumer transparency
- **Modern UI** with Shadcn/ui components
- **Real-time updates** across all connected users
- **Product catalog** with search and filtering

### **5. Supply Chain Transparency**
- Complete product journey from farm to consumer
- Stakeholder verification at each stage
- Public batch information accessible via QR codes
- Trust-building through radical transparency

---

## 🛠 Tech Stack

### **Frontend Applications**

<table>
<tr>
<td width="50%" valign="top">

#### **Mobile App (Flutter)**
```yaml
Framework: Flutter 3.0+
Language: Dart
State Management: Provider
Platform: Android & iOS
```

**Key Dependencies:**
- `firebase_core` & `firebase_auth` - Authentication
- `firebase_database` - Real-time data sync
- `web3dart` - Blockchain interaction
- `nfc_manager` - NFC tag reading
- `qr_flutter` - QR code generation
- `go_router` - Navigation
- `google_sign_in` - OAuth authentication

</td>
<td width="50%" valign="top">

#### **Web App (React)**
```json
Framework: React 18.3 + Vite
Language: TypeScript
UI: Shadcn/ui (Radix UI)
Styling: Tailwind CSS
```

**Key Dependencies:**
- `ethers` - Ethereum blockchain library
- `firebase` - Firebase SDK
- `react-router-dom` - Client-side routing
- `qrcode.react` - QR code generation
- `recharts` - Data visualization
- `react-hook-form` + `zod` - Form validation

</td>
</tr>
</table>

### **Backend & Blockchain**

#### **Smart Contract (Solidity)**
```solidity
// contracts/BatchTracking.sol
pragma solidity ^0.8.0;

contract BatchTracking {
    // Immutable batch records
    // Quality metrics tracking
    // NFC authentication
    // Event logging
}
```

**Deployment:**
- **Local Development:** Ganache (Ethereum simulator)
- **Testnet:** Sepolia Ethereum Testnet
- **Tools:** Truffle Suite for compilation and migration

#### **Firebase Integration**
- **Realtime Database** - Instant data synchronization
- **Authentication** - Email/password and Google OAuth
- **Cloud Functions** - Serverless backend logic (optional)
- **Security Rules** - Role-based access control

---

## 🏗 System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        End Users                            │
│   👨‍🌾 Farmers  👨‍🔬 Inspectors  🚚 Distributors  👤 Consumers  │
└────────────┬───────────────────────────────────┬────────────┘
             │                                   │
      ┌──────▼──────┐                     ┌──────▼──────┐
      │  Mobile App │                     │   Web App   │
      │  (Flutter)  │                     │   (React)   │
      └──────┬──────┘                     └──────┬──────┘
             │                                   │
             └───────────┬───────────────────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
    ┌─────▼─────┐  ┌─────▼─────┐  ┌────▼────┐
    │  Firebase │  │ Blockchain │  │   NFC   │
    │  Realtime │  │  Ethereum  │  │  Tags   │
    │  Database │  │  Network   │  │ (HW)    │
    └───────────┘  └───────────┘  └─────────┘
         │              │              │
         └──────────────┴──────────────┘
                        │
              ┌─────────▼─────────┐
              │  Smart Contract   │
              │ BatchTracking.sol │
              └───────────────────┘
```

### **Data Flow**

1. **Batch Creation**: User creates batch → Data saved to Firebase → Transaction sent to blockchain → Confirmation returned
2. **Quality Metrics**: Inspector adds metrics → Stored in Firebase → Recorded on blockchain → Multi-signature verification
3. **NFC Authentication**: Consumer scans tag → App queries blockchain → Verifies authenticity → Displays batch information
4. **Real-time Sync**: Any update → Firebase triggers → All connected clients receive update → UI updates automatically

---

## 🚦 Getting Started

### **Prerequisites**

- **Node.js** 18+ and npm
- **Flutter** 3.0+ and Dart SDK
- **Ganache** (for local blockchain)
- **Firebase** account
- **MetaMask** or Web3 wallet (for blockchain interaction)

### **Installation**

#### **1. Clone the Repository**
```bash
git clone https://github.com/yourusername/vriksha-chain.git
cd vriksha-chain
```

#### **2. Web App Setup**

```bash
# Install dependencies
npm install

# Configure Firebase
# Create .env file with your Firebase config
cat > .env << EOF
VITE_FIREBASE_API_KEY=your_api_key
VITE_FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
VITE_FIREBASE_PROJECT_ID=your_project_id
VITE_FIREBASE_STORAGE_BUCKET=your_project.appspot.com
VITE_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
VITE_FIREBASE_APP_ID=your_app_id
EOF

# Start local blockchain (in separate terminal)
npx ganache

# Deploy smart contracts
npx truffle migrate --reset

# Start development server
npm run dev
```

The web app will be available at `http://localhost:5173`

#### **3. Mobile App Setup**

```bash
# Navigate to app directory
cd app

# Install Flutter dependencies
flutter pub get

# Configure Firebase for Flutter
# Add google-services.json (Android) and GoogleService-Info.plist (iOS)

# Update smart contract ABI and address
# Copy from build/contracts/BatchTracking.json to assets/contracts/

# Run on emulator/device
flutter run
```

### **Firebase Configuration**

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** (Email/Password and Google providers)
3. Create **Realtime Database** with security rules
4. Add web app and download config for `.env` file
5. For mobile: Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)

### **Blockchain Setup**

```bash
# Install Truffle globally
npm install -g truffle

# Compile smart contracts
truffle compile

# Start Ganache (local Ethereum)
ganache --deterministic

# Deploy contracts
truffle migrate --reset --network development

# Copy contract ABI and address to apps
# Web: Update src/contracts/
# Mobile: Update app/assets/contracts/
```

---

## 📱 Platform-Specific Features

### **Mobile App (Flutter)**

<table>
<tr>
<th>Feature</th>
<th>Description</th>
</tr>
<tr>
<td><strong>🔐 Authentication</strong></td>
<td>Firebase Auth with Google Sign-In and email/password</td>
</tr>
<tr>
<td><strong>📦 Batch Management</strong></td>
<td>Create, view, and track batches with offline support</td>
</tr>
<tr>
<td><strong>📱 NFC Reading</strong></td>
<td>Scan NFC tags for instant product verification</td>
</tr>
<tr>
<td><strong>📊 Quality Metrics</strong></td>
<td>Record and view quality inspection data</td>
</tr>
<tr>
<td><strong>🔄 Offline Mode</strong></td>
<td>Work without internet, sync when connected</td>
</tr>
<tr>
<td><strong>📲 QR Generation</strong></td>
<td>Create QR codes for batch sharing</td>
</tr>
</table>

**Key Screens:**
- Login & Registration
- Dashboard with statistics
- Batch list and detail views
- Batch creation form
- NFC scanner
- QR code display
- Quality metrics logger
- Profile management

### **Web App (React)**

<table>
<tr>
<th>Feature</th>
<th>Description</th>
</tr>
<tr>
<td><strong>📊 Analytics Dashboard</strong></td>
<td>Visual insights with charts and metrics</td>
</tr>
<tr>
<td><strong>🗂️ Batch Catalog</strong></td>
<td>Searchable, filterable product directory</td>
</tr>
<tr>
<td><strong>🌐 Public Verification</strong></td>
<td>Consumer-facing batch verification pages</td>
</tr>
<tr>
<td><strong>⚡ Real-time Updates</strong></td>
<td>Live data sync across all users</td>
</tr>
<tr>
<td><strong>📱 Responsive Design</strong></td>
<td>Works on desktop, tablet, and mobile browsers</td>
</tr>
<tr>
<td><strong>🎨 Modern UI</strong></td>
<td>Shadcn/ui components with dark mode support</td>
</tr>
</table>

**Key Pages:**
- `/` - Landing page
- `/dashboard` - Analytics and overview
- `/batches` - Batch management
- `/batch/:id` - Batch detail view
- `/verify/:batchId` - Public verification page
- `/profile` - User settings

---

## 🔐 Security Features

- **🔒 Blockchain Immutability** - Data cannot be altered after recording
- **🔐 Multi-signature Verification** - Critical actions require multiple approvals
- **🛡️ Firebase Security Rules** - Role-based access control
- **🔑 Wallet Authentication** - Cryptographic proof of identity
- **📱 NFC Tag Encryption** - Secure tag-to-blockchain linkage
- **🚫 Anti-tampering** - Instant detection of data manipulation attempts

---

## 📸 Demo

### Screenshots

<table>
<tr>
<td width="50%">

#### Mobile App
![Mobile Dashboard](https://via.placeholder.com/400x800?text=Mobile+Dashboard)
*Batch tracking dashboard with real-time statistics*

</td>
<td width="50%">

#### Web App
![Web Dashboard](https://via.placeholder.com/800x400?text=Web+Dashboard)
*Analytics dashboard with supply chain visualization*

</td>
</tr>
</table>

---

## 🗺 Roadmap

- [x] Core blockchain integration
- [x] Firebase real-time sync
- [x] NFC authentication
- [x] Mobile app (Android/iOS)
- [x] Web application
- [x] QR code verification
- [ ] Multi-language support
- [ ] Advanced analytics and reporting
- [ ] Integration with IoT sensors
- [ ] Marketplace for verified products
- [ ] Carbon footprint tracking
- [ ] Supply chain financing features

---

## 📄 Project Structure

```
vriksha-chain/
├── app/                          # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart            # App entry point
│   │   ├── models/              # Data models
│   │   ├── providers/           # State management (Provider)
│   │   ├── routes/              # Navigation routes
│   │   ├── screens/             # UI screens
│   │   ├── services/            # Blockchain & Firebase services
│   │   └── widgets/             # Reusable UI components
│   ├── assets/
│   │   ├── contracts/           # Smart contract ABIs
│   │   └── images/              # App images and icons
│   ├── android/                 # Android-specific files
│   ├── ios/                     # iOS-specific files
│   └── pubspec.yaml             # Flutter dependencies
│
├── src/                         # React web application
│   ├── components/              # Reusable React components
│   ├── contexts/                # React contexts (Auth, Blockchain)
│   ├── hooks/                   # Custom React hooks
│   ├── lib/                     # Utility functions
│   ├── pages/                   # Page components
│   ├── services/                # API and blockchain services
│   ├── App.tsx                  # Main app component
│   └── main.tsx                 # Entry point
│
├── contracts/                   # Solidity smart contracts
│   └── BatchTracking.sol        # Main supply chain contract
│
├── migrations/                  # Truffle migration scripts
│   └── 1_deploy_contracts.cjs   # Contract deployment
│
├── build/                       # Compiled contracts (ABIs)
│   └── contracts/
│       └── BatchTracking.json   # Contract ABI and metadata
│
├── public/                      # Static web assets
├── package.json                 # Node.js dependencies
├── truffle-config.cjs           # Truffle configuration
├── vite.config.ts               # Vite configuration
├── tailwind.config.ts           # Tailwind CSS config
└── firebase.json                # Firebase configuration
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👥 Team

- **Project Type:** Academic/Commercial Project
- **Target Industry:** Agricultural Supply Chain, Herbal Products
- **Technology Focus:** Blockchain, IoT, Mobile Development

---

## 📧 Contact & Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/vriksha-chain/issues)
- **Email:** your.email@example.com
- **Documentation:** [Wiki](https://github.com/yourusername/vriksha-chain/wiki)

---

## 🙏 Acknowledgments

- **Ethereum Foundation** - For blockchain technology
- **Firebase** - For real-time database and authentication
- **Flutter Team** - For cross-platform mobile framework
- **React Community** - For web framework and components
- **Shadcn/ui** - For beautiful UI components

---

<div align="center">

### ⭐ Star this repository if you find it useful!

**Made with ❤️ for a transparent and sustainable agricultural future**

</div>
- System checks if tag ID matches blockchain record
- Logs every authentication attempt with timestamp and location

### **3. Quality Metrics & Certifications**
- Quality inspectors record test results on blockchain
- Metrics include: Temperature, pH level, moisture content, purity
- Inspector's wallet address recorded for accountability
- Immutable audit trail of all quality checks
- Certifications linked to batches permanently

### **4. Dual Verification (Hybrid Architecture)**
```
User Action
    ↓
Firebase (Fast Read/Write) ← → Blockchain (Verification)
    ↓                              ↓
Real-time UI Update          Immutable Record
```
- Data written to both Firebase and blockchain simultaneously
- Firebase provides instant UI updates
- Blockchain ensures data integrity
- System alerts if discrepancies detected

### **5. Public Verification via QR Codes**
- Each batch generates a unique QR code
- QR code links to public verification page
- No authentication required to verify product authenticity
- Shows complete supply chain journey
- Displays blockchain transaction hash as proof

### **6. Real-time Multi-platform Sync**
- Changes made on mobile instantly reflect on web (and vice versa)
- Firebase Realtime Database streams for live updates
- Shared authentication across platforms
- Consistent user experience

### **7. Analytics Dashboard**
- Total batches created and tracked
- Quality metrics trends over time
- Supply chain bottleneck identification
- Product distribution visualization
- Blockchain transaction history

---

## 📱 User Flows

### **Farmer Journey:**
1. Creates account and logs in (email or Google)
2. Creates new batch with product details
3. System generates NFC tag ID and blockchain record
4. Attaches physical NFC tag to product packaging
5. Generates QR code for public verification
6. Tracks batch through supply chain stages

### **Quality Inspector Journey:**
1. Scans NFC tag on product
2. System verifies batch exists on blockchain
3. Performs quality tests (temperature, pH, etc.)
4. Records metrics directly to blockchain
5. Inspector's wallet address permanently linked to inspection
6. Certification issued if quality standards met

### **Consumer Journey:**
1. Scans QR code on product packaging (no login required)
2. Views complete product journey:
   - Farm origin and harvest date
   - Quality inspection results
   - Supply chain timeline
   - Blockchain verification proof
3. Can optionally scan NFC tag for additional authentication
4. Sees real-time blockchain transaction hash

---

## 🛠️ Technical Implementation Highlights

### **Smart Contract Security**
- Ownable pattern for access control
- Event emission for transparency
- Input validation and require statements
- Gas-optimized storage patterns
- Comprehensive error handling

### **Mobile App Architecture**
```
lib/
├── services/
│   ├── blockchain_service.dart    # Web3 integration
│   ├── firebase_service.dart      # Firebase CRUD operations
│   ├── auth_service.dart          # Authentication logic
│   ├── nfc_service.dart           # NFC tag reading
│   └── database_service.dart      # Local caching
├── screens/
│   ├── dashboard_screen.dart      # Main overview
│   ├── batches_screen.dart        # Batch management
│   ├── blockchain_test_screen.dart # Testing interface
│   └── quality_metrics_screen.dart # Quality tracking
├── models/
│   ├── batch_model.dart
│   └── quality_metric_model.dart
└── providers/
    ├── auth_provider.dart         # State management
    └── batch_provider.dart
```

### **Web App Architecture**
```
src/
├── services/
│   └── blockchainService.ts       # Ethers.js integration
├── contexts/
│   └── AuthContext.tsx            # Firebase auth context
├── hooks/
│   └── useFirebaseData.ts         # Real-time data hooks
├── components/
│   ├── BatchManagement.tsx        # Batch CRUD
│   ├── BatchQRCode.tsx            # QR generation
│   └── Header.tsx                 # Navigation
└── pages/
    ├── Dashboard.tsx              # Main dashboard
    ├── SupplyChain.tsx            # Supply chain view
    ├── PublicBatch.tsx            # Public verification
    └── Analytics.tsx              # Charts and metrics
```

---

## 🚀 Deployment & Testing

### **Local Development:**
- **Blockchain:** Ganache CLI (local Ethereum node)
- **Smart Contracts:** Truffle framework for compilation and deployment
- **Web App:** Vite dev server (port 5173)
- **Mobile App:** Flutter hot reload on Android/iOS emulators

### **Production Setup:**
- **Blockchain:** Sepolia testnet (or Polygon for lower gas fees)
- **Web Hosting:** Firebase Hosting / Vercel
- **Mobile Distribution:** Google Play Store & Apple App Store
- **Database:** Firebase Realtime Database (production instance)
- **Authentication:** Firebase Authentication with OAuth providers

### **Contract Deployment:**
```bash
# Compile contracts
truffle compile

# Deploy to local Ganache
truffle migrate

# Deploy to testnet
truffle migrate --network sepolia
```

### **APK Build:**
```bash
cd app
flutter build apk --release
# Output: app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 📊 Database Schema

### **Firebase Structure:**
```json
{
  "batches": {
    "batch-id": {
      "batchId": "string",
      "productName": "string",
      "quantity": "number",
      "harvestDate": "timestamp",
      "nfcTagId": "string",
      "blockchainTxHash": "string",
      "status": "enum"
    }
  },
  "qualityMetrics": {
    "metric-id": {
      "batchId": "string",
      "temperature": "number",
      "pH": "number",
      "timestamp": "timestamp",
      "inspectorAddress": "string"
    }
  }
}
```

### **Blockchain Storage:**
- All batch data mirrored on-chain
- Permanent, immutable records
- Gas-optimized for cost efficiency
- Event logs for change tracking

---

## 🎯 Impact & Use Cases

### **For Farmers:**
- Prove product authenticity and origin
- Build consumer trust through transparency
- Access premium markets requiring verification
- Reduce intermediary fraud

### **For Consumers:**
- Verify product authenticity instantly
- See complete supply chain journey
- Make informed purchasing decisions
- Trust in product quality

### **For Regulators:**
- Audit trail for compliance verification
- Instant access to quality records
- Fraud detection and prevention
- Transparent supply chain monitoring

### **For Retailers:**
- Verify supplier claims
- Quality assurance documentation
- Reduced liability from counterfeit products
- Enhanced brand reputation

---

## 🏆 Competitive Advantages

1. **Hybrid Architecture** - Combines blockchain security with cloud speed
2. **NFC + QR** - Physical-digital verification bridge
3. **Cross-platform** - Single codebase for web and mobile (shared Firebase)
4. **User-friendly** - No crypto knowledge required for end users
5. **Cost-effective** - Optimized gas usage, local blockchain option
6. **Open & Transparent** - Public verification without authentication
7. **Production-ready** - Complete with APK builds and deployment configs

---

## 📈 Future Enhancements

- **IoT Integration:** Temperature sensors auto-reporting to blockchain
- **AI Quality Prediction:** Machine learning for quality forecasting
- **Multi-chain Support:** Deploy on Polygon/BSC for lower fees
- **Supply Chain Finance:** Smart contracts for automated payments
- **Satellite Tracking:** GPS coordinates stored on blockchain
- **Carbon Footprint Tracking:** Environmental impact monitoring
- **Multi-language Support:** Internationalization for global reach

---

## 🔧 Technologies Used

**Frontend:**
- Flutter 3.0+ (Dart)
- React 18 + TypeScript
- Vite build tool
- Tailwind CSS + Shadcn/ui
- React Query for data fetching

**Blockchain:**
- Solidity ^0.8.0
- Truffle Suite
- Ganache CLI
- web3dart (Flutter)
- ethers.js (Web)

**Backend Services:**
- Firebase Authentication
- Firebase Realtime Database
- Firebase Cloud Storage
- Firebase Hosting

**Additional Libraries:**
- nfc_manager (Flutter NFC)
- qr_flutter (QR generation)
- go_router (Flutter navigation)
- provider (State management)

---

## 📦 Deliverables

✅ **Smart Contract** - Deployed and verified BatchTracking.sol  
✅ **Flutter Mobile App** - Android APK (54.4 MB release build)  
✅ **Web Application** - Deployed on Firebase Hosting  
✅ **Documentation** - 14 comprehensive markdown guides  
✅ **Source Code** - Complete GitHub repository  
✅ **Test Environment** - Ganache local blockchain setup  
✅ **Contract ABI** - JSON artifacts for integration  

---

## 👥 Team & Acknowledgments

**Project Name:** VrikshaChain  
**Repository:** github.com/adityamaitreya/vriksha-chain  
**License:** MIT  

---

## 🎬 Demo Instructions

### **Quick Start:**

1. **Start Local Blockchain:**
   ```bash
   ganache --host 0.0.0.0 --port 8545
   ```

2. **Deploy Smart Contract:**
   ```bash
   truffle migrate
   ```

3. **Run Web App:**
   ```bash
   npm install && npm run dev
   ```

4. **Install Mobile APK:**
   - Transfer `app-release.apk` to Android device
   - Enable "Install from Unknown Sources"
   - Install and launch VrikshaChain app

5. **Create Test Batch:**
   - Login with email or Google
   - Navigate to "Batches" → "Create New"
   - Fill product details
   - System creates blockchain record automatically

6. **Verify on Blockchain:**
   - View transaction hash in app
   - Check Ganache for confirmed transaction
   - Scan QR code for public verification

---

## 📞 Contact & Resources

**GitHub:** [vriksha-chain repository](https://github.com/adityamaitreya/vriksha-chain)  
**Documentation:** See START_HERE.md in root directory  
**Setup Guide:** See BLOCKCHAIN_SETUP.md for complete installation  
**Smart Contract:** BatchTracking.sol  

---

**VrikshaChain** - *Bringing transparency and trust to the agricultural supply chain through blockchain technology* 🌱⛓️
