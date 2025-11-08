import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web3dart/crypto.dart';

class BlockchainService {
  static final BlockchainService _instance = BlockchainService._internal();
  factory BlockchainService() => _instance;
  BlockchainService._internal();

  // Configuration
  static const String _rpcUrl = 'http://192.168.0.215:8545'; // Physical device - direct connection
  // Using computer's IP since ADB port forwarding isn't working
  
  late Web3Client _client;
  late DeployedContract _contract;
  late EthPrivateKey _credentials;
  final _storage = const FlutterSecureStorage();
  
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      print('🔗 Initializing blockchain service...');
      
      // Initialize Web3 client
      _client = Web3Client(_rpcUrl, Client());
      
      // Load contract ABI
      final abiString = await rootBundle.loadString('assets/contracts/BatchTracking.json');
      final abiJson = jsonDecode(abiString);
      
      // Get contract address
      String? contractAddress = await _storage.read(key: 'contract_address');
      
      if (contractAddress == null || contractAddress.isEmpty) {
        throw Exception(
          'Contract address not set. Please deploy contract and set address using setContractAddress()'
        );
      }
      
      print('📄 Contract address: $contractAddress');
      
      _contract = DeployedContract(
        ContractAbi.fromJson(jsonEncode(abiJson['abi']), 'BatchTracking'),
        EthereumAddress.fromHex(contractAddress),
      );
      
      // Load or create credentials
      await _loadOrCreateCredentials();
      
      _initialized = true;
      print('✅ Blockchain service initialized');
      print('👛 Wallet: ${await getWalletAddress()}');
      print('💰 Balance: ${await getBalance()} ETH');
    } catch (e) {
      print('❌ Error initializing blockchain: $e');
      rethrow;
    }
  }
  
  Future<void> _loadOrCreateCredentials() async {
    String? privateKeyHex = await _storage.read(key: 'private_key');
    
    if (privateKeyHex == null) {
      _credentials = EthPrivateKey.createRandom(Random.secure());
      await _storage.write(
        key: 'private_key',
        value: bytesToHex(_credentials.privateKey),
      );
      print('🆕 New wallet created');
    } else {
      _credentials = EthPrivateKey.fromHex(privateKeyHex);
      print('📂 Wallet loaded from storage');
    }
  }
  
  Future<void> setContractAddress(String address) async {
    await _storage.write(key: 'contract_address', value: address);
    _initialized = false;
  }
  
  Future<String> getContractAddress() async {
    return await _storage.read(key: 'contract_address') ?? '';
  }
  
  Future<String> getWalletAddress() async {
    final address = await _credentials.extractAddress();
    return address.hex;
  }
  
  Future<double> getBalance() async {
    try {
      final address = await _credentials.extractAddress();
      final balance = await _client.getBalance(address);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e) {
      print('Error getting balance: $e');
      return 0.0;
    }
  }
  
  Future<bool> isConnected() async {
    try {
      await _client.getBlockNumber();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // ============== BATCH FUNCTIONS ==============
  
  Future<String> createBatch({
    required String batchId,
    required String productName,
    required String variety,
    required int quantity,
    required String unit,
    required String location,
    required DateTime harvestDate,
    required DateTime expiryDate,
    required String nfcTagId,
  }) async {
    await initialize();
    
    try {
      print('📦 Creating batch on blockchain: $batchId');
      
      final function = _contract.function('createBatch');
      
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
      
      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 1337,
      );
      
      print('📤 Transaction sent: $txHash');
      await _waitForTransaction(txHash);
      print('✅ Batch created successfully');
      
      return txHash;
    } catch (e) {
      print('❌ Error creating batch: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>?> getBatch(String batchId) async {
    await initialize();
    
    try {
      final function = _contract.function('getBatch');
      
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [batchId],
      );
      
      if (result.isEmpty) return null;
      
      return {
        'productName': result[0] as String,
        'variety': result[1] as String,
        'quantity': (result[2] as BigInt).toInt(),
        'unit': result[3] as String,
        'location': result[4] as String,
        'harvestDate': DateTime.fromMillisecondsSinceEpoch(
          (result[5] as BigInt).toInt() * 1000,
        ),
        'expiryDate': DateTime.fromMillisecondsSinceEpoch(
          (result[6] as BigInt).toInt() * 1000,
        ),
        'nfcTagId': result[7] as String,
        'creator': (result[8] as EthereumAddress).hex,
        'timestamp': DateTime.fromMillisecondsSinceEpoch(
          (result[9] as BigInt).toInt() * 1000,
        ),
      };
    } catch (e) {
      print('❌ Error getting batch: $e');
      return null;
    }
  }
  
  Future<String> addQualityMetric({
    required String metricId,
    required String batchId,
    required String metricType,
    required String value,
    required String unit,
  }) async {
    await initialize();
    
    try {
      final function = _contract.function('addQualityMetric');
      
      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [metricId, batchId, metricType, value, unit],
        maxGas: 2000000,
      );
      
      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 1337,
      );
      
      await _waitForTransaction(txHash);
      return txHash;
    } catch (e) {
      print('❌ Error adding quality metric: $e');
      rethrow;
    }
  }
  
  Future<Map<String, dynamic>> authenticateNFC({
    required String authId,
    required String batchId,
    required String nfcTagId,
    required String location,
  }) async {
    await initialize();
    
    try {
      print('🔐 Authenticating NFC on blockchain...');
      
      final function = _contract.function('authenticateNFC');
      
      final transaction = Transaction.callContract(
        contract: _contract,
        function: function,
        parameters: [authId, batchId, nfcTagId, location],
        maxGas: 2000000,
      );
      
      final txHash = await _client.sendTransaction(
        _credentials,
        transaction,
        chainId: 1337,
      );
      
      final receipt = await _waitForTransaction(txHash);
      
      // Check authentication result
      final isValid = await _checkAuthResult(batchId, nfcTagId);
      
      print('✅ NFC authenticated. Valid: $isValid');
      
      return {
        'txHash': txHash,
        'isValid': isValid,
        'blockNumber': receipt.blockNumber.blockNum.toInt(),
      };
    } catch (e) {
      print('❌ Error authenticating NFC: $e');
      rethrow;
    }
  }
  
  Future<bool> _checkAuthResult(String batchId, String nfcTagId) async {
    try {
      final batch = await getBatch(batchId);
      return batch?['nfcTagId'] == nfcTagId;
    } catch (e) {
      return false;
    }
  }
  
  Future<int> getTotalBatches() async {
    await initialize();
    
    try {
      final function = _contract.function('getTotalBatches');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );
      return (result[0] as BigInt).toInt();
    } catch (e) {
      return 0;
    }
  }
  
  Future<List<String>> getAllBatchIds() async {
    await initialize();
    
    try {
      final function = _contract.function('getAllBatchIds');
      final result = await _client.call(
        contract: _contract,
        function: function,
        params: [],
      );
      return (result[0] as List).map((e) => e.toString()).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<TransactionReceipt> _waitForTransaction(String txHash) async {
    const maxAttempts = 60;
    const delay = Duration(seconds: 2);
    
    print('⏳ Waiting for confirmation...');
    
    for (var i = 0; i < maxAttempts; i++) {
      try {
        final receipt = await _client.getTransactionReceipt(txHash);
        if (receipt != null) {
          print('✓ Confirmed in block ${receipt.blockNumber}');
          return receipt;
        }
      } catch (e) {
        // Continue waiting
      }
      await Future.delayed(delay);
    }
    
    throw Exception('Transaction timeout');
  }
  
  void dispose() {
    _client.dispose();
  }
}
