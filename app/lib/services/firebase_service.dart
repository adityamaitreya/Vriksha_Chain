import 'package:firebase_database/firebase_database.dart';
import 'blockchain_service.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final _blockchain = BlockchainService();

  DatabaseReference get batchesRef => 
      FirebaseDatabase.instance.ref().child('batches');
  
  DatabaseReference get qualityMetricsRef => 
      FirebaseDatabase.instance.ref().child('qualityMetrics');
  
  DatabaseReference get certificationsRef => 
      FirebaseDatabase.instance.ref().child('certifications');
  
  DatabaseReference get statsRef => 
      FirebaseDatabase.instance.ref().child('stats');
  
  DatabaseReference get nfcAuthenticationsRef => 
      FirebaseDatabase.instance.ref().child('nfcAuthentications');
  
  // Get batch reference
  DatabaseReference batchRef(String id) => 
      FirebaseDatabase.instance.ref().child('batches').child(id);
  
  // Get quality metric reference
  DatabaseReference qualityMetricRef(String id) => 
      FirebaseDatabase.instance.ref().child('qualityMetrics').child(id);
  
  // Get certification reference
  DatabaseReference certificationRef(String id) => 
      FirebaseDatabase.instance.ref().child('certifications').child(id);
  
  // Get NFC authentication reference
  DatabaseReference nfcAuthenticationRef(String id) => 
      FirebaseDatabase.instance.ref().child('nfcAuthentications').child(id);
  
  // Get NFC authentications for a batch
  Query batchNfcAuthenticationsRef(String batchId) => 
      FirebaseDatabase.instance.ref().child('nfcAuthentications')
          .orderByChild('batchId').equalTo(batchId);

  // ============== BLOCKCHAIN INTEGRATION ==============
  
  /// Create batch with blockchain verification
  Future<Map<String, dynamic>> createBatchWithBlockchain({
    required String batchId,
    required Map<String, dynamic> batchData,
  }) async {
    try {
      print('Creating batch with blockchain integration...');
      
      // 1. Create on blockchain first (immutable record)
      final txHash = await _blockchain.createBatch(
        batchId: batchId,
        productName: batchData['productName'] ?? '',
        variety: batchData['variety'] ?? '',
        quantity: batchData['quantity'] ?? 0,
        unit: batchData['unit'] ?? 'kg',
        location: batchData['location'] ?? '',
        harvestDate: DateTime.parse(batchData['harvestDate']),
        expiryDate: DateTime.parse(batchData['expiryDate']),
        nfcTagId: batchData['nfcTagId'] ?? '',
      );
      
      // 2. Add blockchain data
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
        'message': 'Batch created on both Firebase and Blockchain',
      };
    } catch (e) {
      print('Error creating batch with blockchain: $e');
      
      // Fallback: Save to Firebase only
      await batchRef(batchId).set({
        ...batchData,
        'blockchainVerified': false,
        'blockchainError': e.toString(),
      });
      
      return {
        'success': false,
        'error': e.toString(),
        'batchId': batchId,
        'message': 'Saved to Firebase only. Blockchain error: $e',
      };
    }
  }
  
  /// Authenticate NFC with blockchain verification
  Future<Map<String, dynamic>> authenticateNFCWithBlockchain({
    required String authId,
    required String batchId,
    required String nfcTagId,
    required String location,
  }) async {
    try {
      // 1. Check Firebase batch
      final batchSnapshot = await batchRef(batchId).get();
      if (!batchSnapshot.exists) {
        throw Exception('Batch not found');
      }
      
      final batchData = batchSnapshot.value as Map;
      final storedNfcId = batchData['nfcTagId'];
      
      // 2. Verify on blockchain
      final blockchainResult = await _blockchain.authenticateNFC(
        authId: authId,
        batchId: batchId,
        nfcTagId: nfcTagId,
        location: location,
      );
      
      // 3. Cross-verify
      final isFirebaseValid = storedNfcId == nfcTagId;
      final isBlockchainValid = blockchainResult['isValid'] as bool;
      final isBothValid = isFirebaseValid && isBlockchainValid;
      
      // 4. Save authentication record
      final authData = {
        'authId': authId,
        'batchId': batchId,
        'nfcTagId': nfcTagId,
        'location': location,
        'timestamp': DateTime.now().toIso8601String(),
        'isValid': isBothValid,
        'firebaseValid': isFirebaseValid,
        'blockchainValid': isBlockchainValid,
        'blockchainTxHash': blockchainResult['txHash'],
        'verificationType': 'dual',
      };
      
      await nfcAuthenticationRef(authId).set(authData);
      
      return {
        'success': true,
        'isValid': isBothValid,
        'firebaseValid': isFirebaseValid,
        'blockchainValid': isBlockchainValid,
        'txHash': blockchainResult['txHash'],
        'message': isBothValid 
            ? '✅ Verified on both Firebase and Blockchain' 
            : '❌ Verification failed',
      };
    } catch (e) {
      print('Error authenticating NFC with blockchain: $e');
      return {
        'success': false,
        'isValid': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Verify batch authenticity
  Future<Map<String, dynamic>> verifyBatchAuthenticity(String batchId) async {
    try {
      // 1. Get Firebase data
      final firebaseSnapshot = await batchRef(batchId).get();
      if (!firebaseSnapshot.exists) {
        return {
          'verified': false,
          'error': 'Batch not found in Firebase',
        };
      }
      
      final firebaseData = firebaseSnapshot.value as Map;
      
      // 2. Get Blockchain data
      final blockchainData = await _blockchain.getBatch(batchId);
      if (blockchainData == null) {
        return {
          'verified': false,
          'error': 'Batch not found on Blockchain',
          'firebaseExists': true,
          'blockchainExists': false,
        };
      }
      
      // 3. Compare critical fields
      final productNameMatch = firebaseData['productName'] == blockchainData['productName'];
      final nfcTagMatch = firebaseData['nfcTagId'] == blockchainData['nfcTagId'];
      final varietyMatch = firebaseData['variety'] == blockchainData['variety'];
      
      final isVerified = productNameMatch && nfcTagMatch && varietyMatch;
      
      return {
        'verified': isVerified,
        'productNameMatch': productNameMatch,
        'nfcTagMatch': nfcTagMatch,
        'varietyMatch': varietyMatch,
        'blockchainCreator': blockchainData['creator'],
        'blockchainTimestamp': blockchainData['timestamp'],
      };
    } catch (e) {
      return {
        'verified': false,
        'error': e.toString(),
      };
    }
  }
  
  /// Get blockchain service (for direct access)
  BlockchainService get blockchain => _blockchain;
}

