import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/blockchain_service.dart';
import '../services/firebase_service.dart';

class BlockchainTestScreen extends StatefulWidget {
  const BlockchainTestScreen({Key? key}) : super(key: key);

  @override
  State<BlockchainTestScreen> createState() => _BlockchainTestScreenState();
}

class _BlockchainTestScreenState extends State<BlockchainTestScreen> {
  final _blockchain = BlockchainService();
  final _firebase = FirebaseService();
  final _contractAddressController = TextEditingController();
  
  String _status = 'Not initialized';
  String _walletAddress = '';
  String _balance = '';
  String _contractAddress = '';
  bool _isConnected = false;
  bool _loading = false;
  int _totalBatches = 0;

  @override
  void initState() {
    super.initState();
    _loadContractAddress();
    // Pre-fill with deployed contract address
    _contractAddressController.text = '0x3380916E6b27100491c63c6f570627E60ff3cd53';
  }

  Future<void> _loadContractAddress() async {
    final address = await _blockchain.getContractAddress();
    if (address.isNotEmpty) {
      setState(() {
        _contractAddress = address;
        _contractAddressController.text = address;
      });
    }
  }

  Future<void> _saveContractAddress() async {
    final address = _contractAddressController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter contract address');
      return;
    }

    try {
      await _blockchain.setContractAddress(address);
      setState(() {
        _contractAddress = address;
        _status = 'Contract address saved. Click "Initialize" to connect.';
      });
      _showSuccess('Contract address saved!');
    } catch (e) {
      _showError('Error saving address: $e');
    }
  }

  Future<void> _initialize() async {
    setState(() {
      _loading = true;
      _status = 'Initializing blockchain service...';
    });

    try {
      await _blockchain.initialize();
      
      final address = await _blockchain.getWalletAddress();
      final balance = await _blockchain.getBalance();
      final connected = await _blockchain.isConnected();
      final total = await _blockchain.getTotalBatches();

      setState(() {
        _walletAddress = address;
        _balance = balance.toStringAsFixed(4);
        _isConnected = connected;
        _totalBatches = total;
        _status = connected ? '✅ Connected to blockchain' : '❌ Not connected';
        _loading = false;
      });

      if (connected) {
        _showSuccess('Blockchain initialized successfully!');
      } else {
        _showError('Cannot connect to blockchain. Is Ganache running?');
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _loading = false;
      });
      _showError('Initialization failed: $e');
    }
  }

  Future<void> _createTestBatch() async {
    setState(() {
      _loading = true;
      _status = 'Creating test batch on blockchain...';
    });

    try {
      final batchId = 'TEST_${DateTime.now().millisecondsSinceEpoch}';
      final batchData = {
        'productName': 'Test Tomatoes',
        'variety': 'Cherry',
        'quantity': 100,
        'unit': 'kg',
        'location': 'Test Farm',
        'origin': 'Test Farm',
        'destination': 'Test Market',
        'currentLocation': 'Test Farm',
        'harvestDate': DateTime.now().toIso8601String(),
        'expiryDate': DateTime.now().add(Duration(days: 7)).toIso8601String(),
        'nfcTagId': 'TEST_NFC_${DateTime.now().millisecondsSinceEpoch}',
        'status': 'Harvested',
        'timestamp': DateTime.now().toIso8601String(),
      };

      final result = await _firebase.createBatchWithBlockchain(
        batchId: batchId,
        batchData: batchData,
      );

      if (result['success']) {
        setState(() {
          _status = '✅ Batch created!\nBatch ID: $batchId\nTX Hash: ${result['txHash']}';
          _loading = false;
        });
        _showSuccess('Test batch created successfully!');
        
        // Refresh total batches
        final total = await _blockchain.getTotalBatches();
        setState(() => _totalBatches = total);
      } else {
        setState(() {
          _status = '❌ Error: ${result['error']}';
          _loading = false;
        });
        _showError('Failed to create batch');
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _loading = false;
      });
      _showError('Error: $e');
    }
  }

  Future<void> _testNFCAuth() async {
    // Get a test batch first
    setState(() {
      _loading = true;
      _status = 'Testing NFC authentication...';
    });

    try {
      final batchIds = await _blockchain.getAllBatchIds();
      
      if (batchIds.isEmpty) {
        _showError('No batches found. Create a test batch first.');
        setState(() => _loading = false);
        return;
      }

      final testBatchId = batchIds.first;
      final batch = await _blockchain.getBatch(testBatchId);
      
      if (batch == null) {
        _showError('Could not fetch batch details');
        setState(() => _loading = false);
        return;
      }

      final authId = 'AUTH_${DateTime.now().millisecondsSinceEpoch}';
      
      final result = await _firebase.authenticateNFCWithBlockchain(
        authId: authId,
        batchId: testBatchId,
        nfcTagId: batch['nfcTagId'],
        location: 'Test Location',
      );

      if (result['success']) {
        setState(() {
          _status = '${result['isValid'] ? '✅' : '❌'} NFC Authentication\n'
                    'Valid: ${result['isValid']}\n'
                    'Firebase: ${result['firebaseValid']}\n'
                    'Blockchain: ${result['blockchainValid']}\n'
                    'TX Hash: ${result['txHash']}';
          _loading = false;
        });
        _showSuccess(result['message']);
      } else {
        setState(() {
          _status = '❌ Error: ${result['error']}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _loading = false;
      });
      _showError('Error: $e');
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blockchain Testing'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Contract Address Setup
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contract Address Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _contractAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Contract Address',
                        hintText: '0x...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _saveContractAddress,
                      child: const Text('Save Contract Address'),
                    ),
                    if (_contractAddress.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Current: $_contractAddress',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Wallet Info
            if (_walletAddress.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wallet Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('Address', _walletAddress),
                      _buildInfoRow('Balance', '$_balance ETH'),
                      _buildInfoRow('Total Batches', _totalBatches.toString()),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _loading ? null : _initialize,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Initialize Blockchain'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_loading || !_isConnected) ? null : _createTestBatch,
              icon: const Icon(Icons.add),
              label: const Text('Create Test Batch'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: (_loading || !_isConnected) ? null : _testNFCAuth,
              icon: const Icon(Icons.nfc),
              label: const Text('Test NFC Authentication'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),

            if (_loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),

            const SizedBox(height: 24),

            // Instructions
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('1. Start Ganache on your computer'),
                    const Text('2. Deploy the smart contract using Truffle'),
                    const Text('3. Copy the contract address from deployment'),
                    const Text('4. Paste it above and save'),
                    const Text('5. Click "Initialize Blockchain"'),
                    const Text('6. Run tests'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contractAddressController.dispose();
    super.dispose();
  }
}
