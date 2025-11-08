import 'package:firebase_database/firebase_database.dart';
import '../models/batch_model.dart';
import '../models/quality_metric_model.dart';
import '../models/nfc_authentication_model.dart';
import 'firebase_service.dart';

class DatabaseService {
  final FirebaseService _firebaseService = FirebaseService();

  // ========== BATCH OPERATIONS ==========
  
  // Create batch
  Future<String?> createBatch(Batch batch) async {
    try {
      final ref = _firebaseService.batchesRef.push();
      await ref.set(batch.copyWith(lastUpdated: DateTime.now().toIso8601String()).toJson());
      return ref.key;
    } catch (e) {
      print('Create batch error: $e');
      return null;
    }
  }

  // Update batch
  Future<bool> updateBatch(String id, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = DateTime.now().toIso8601String();
      await _firebaseService.batchRef(id).update(updates);
      return true;
    } catch (e) {
      print('Update batch error: $e');
      return false;
    }
  }

  // Delete batch
  Future<bool> deleteBatch(String id) async {
    try {
      await _firebaseService.batchRef(id).remove();
      return true;
    } catch (e) {
      print('Delete batch error: $e');
      return false;
    }
  }

  // Get batch stream (real-time)
  Stream<DatabaseEvent> getBatchStream(String id) {
    return _firebaseService.batchRef(id).onValue;
  }

  // Get all batches stream (real-time)
  Stream<DatabaseEvent> getBatchesStream() {
    return _firebaseService.batchesRef.onValue;
  }

  // ========== QUALITY METRICS OPERATIONS ==========

  // Create quality metric
  Future<String?> createQualityMetric(QualityMetric metric) async {
    try {
      final ref = _firebaseService.qualityMetricsRef.push();
      final metricWithTimestamp = QualityMetric(
        id: ref.key!,
        batchId: metric.batchId,
        productName: metric.productName,
        category: metric.category,
        score: metric.score,
        status: metric.status,
        notes: metric.notes,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await ref.set(metricWithTimestamp.toJson());
      return ref.key;
    } catch (e) {
      print('Create quality metric error: $e');
      return null;
    }
  }

  // Update quality metric
  Future<bool> updateQualityMetric(String id, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = DateTime.now().toIso8601String();
      await _firebaseService.qualityMetricRef(id).update(updates);
      return true;
    } catch (e) {
      print('Update quality metric error: $e');
      return false;
    }
  }

  // Delete quality metric
  Future<bool> deleteQualityMetric(String id) async {
    try {
      await _firebaseService.qualityMetricRef(id).remove();
      return true;
    } catch (e) {
      print('Delete quality metric error: $e');
      return false;
    }
  }

  // Get quality metrics stream (real-time)
  Stream<DatabaseEvent> getQualityMetricsStream() {
    return _firebaseService.qualityMetricsRef.onValue;
  }

  // ========== CERTIFICATIONS OPERATIONS ==========

  // Create certification
  Future<String?> createCertification(Certification certification) async {
    try {
      final ref = _firebaseService.certificationsRef.push();
      final certWithTimestamp = Certification(
        id: ref.key!,
        name: certification.name,
        active: certification.active,
        issuedDate: certification.issuedDate,
        expiryDate: certification.expiryDate,
        issuingBody: certification.issuingBody,
        certificateNumber: certification.certificateNumber,
        lastUpdated: DateTime.now().toIso8601String(),
      );
      await ref.set(certWithTimestamp.toJson());
      return ref.key;
    } catch (e) {
      print('Create certification error: $e');
      return null;
    }
  }

  // Update certification
  Future<bool> updateCertification(String id, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = DateTime.now().toIso8601String();
      await _firebaseService.certificationRef(id).update(updates);
      return true;
    } catch (e) {
      print('Update certification error: $e');
      return false;
    }
  }

  // Delete certification
  Future<bool> deleteCertification(String id) async {
    try {
      await _firebaseService.certificationRef(id).remove();
      return true;
    } catch (e) {
      print('Delete certification error: $e');
      return false;
    }
  }

  // Get certifications stream (real-time)
  Stream<DatabaseEvent> getCertificationsStream() {
    return _firebaseService.certificationsRef.onValue;
  }

  // ========== NFC AUTHENTICATION OPERATIONS ==========

  // Create NFC authentication record
  Future<String?> createNFCAuthentication(NFCAuthentication auth) async {
    try {
      final ref = _firebaseService.nfcAuthenticationsRef.push();
      await ref.set(auth.copyWith(id: ref.key!, timestamp: DateTime.now().toIso8601String()).toJson());
      return ref.key;
    } catch (e) {
      print('Create NFC authentication error: $e');
      return null;
    }
  }

  // Get NFC authentications for a batch stream (real-time)
  Stream<DatabaseEvent> getBatchNFCAuthenticationsStream(String batchId) {
    return _firebaseService.batchNfcAuthenticationsRef(batchId).onValue;
  }

  // Get all NFC authentications stream (real-time)
  Stream<DatabaseEvent> getNFCAuthenticationsStream() {
    return _firebaseService.nfcAuthenticationsRef.onValue;
  }
}


