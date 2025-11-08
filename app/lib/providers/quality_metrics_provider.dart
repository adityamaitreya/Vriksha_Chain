import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/quality_metric_model.dart';
import '../services/database_service.dart';

class QualityMetricsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<QualityMetric> _qualityMetrics = [];
  List<Certification> _certifications = [];
  bool _isLoadingMetrics = true;
  bool _isLoadingCertifications = true;
  String? _error;

  List<QualityMetric> get qualityMetrics => _qualityMetrics;
  List<Certification> get certifications => _certifications;
  bool get isLoadingMetrics => _isLoadingMetrics;
  bool get isLoadingCertifications => _isLoadingCertifications;
  String? get error => _error;

  QualityMetricsProvider() {
    _initQualityMetricsStream();
    _initCertificationsStream();
  }

  void _initQualityMetricsStream() {
    _databaseService.getQualityMetricsStream().listen((DatabaseEvent event) {
      try {
        if (event.snapshot.value == null) {
          _qualityMetrics = [];
        } else {
          final Map<dynamic, dynamic> data = 
              event.snapshot.value as Map<dynamic, dynamic>;
          
          _qualityMetrics = data.entries.map((entry) {
            return QualityMetric.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
              entry.key as String,
            );
          }).toList();
        }
        _error = null;
        _isLoadingMetrics = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoadingMetrics = false;
        notifyListeners();
      }
    });
  }

  void _initCertificationsStream() {
    _databaseService.getCertificationsStream().listen((DatabaseEvent event) {
      try {
        if (event.snapshot.value == null) {
          _certifications = [];
        } else {
          final Map<dynamic, dynamic> data = 
              event.snapshot.value as Map<dynamic, dynamic>;
          
          _certifications = data.entries.map((entry) {
            return Certification.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
              entry.key as String,
            );
          }).toList();
        }
        _error = null;
        _isLoadingCertifications = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoadingCertifications = false;
        notifyListeners();
      }
    });
  }

  Future<String?> createQualityMetric(QualityMetric metric) async {
    return await _databaseService.createQualityMetric(metric);
  }

  Future<bool> updateQualityMetric(String id, Map<String, dynamic> updates) async {
    final success = await _databaseService.updateQualityMetric(id, updates);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteQualityMetric(String id) async {
    final success = await _databaseService.deleteQualityMetric(id);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<String?> createCertification(Certification certification) async {
    return await _databaseService.createCertification(certification);
  }

  Future<bool> updateCertification(String id, Map<String, dynamic> updates) async {
    final success = await _databaseService.updateCertification(id, updates);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteCertification(String id) async {
    final success = await _databaseService.deleteCertification(id);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  List<QualityMetric> getMetricsByBatch(String? batchId) {
    if (batchId == null || batchId.isEmpty) {
      return _qualityMetrics.where((m) => m.batchId == null || m.batchId!.isEmpty).toList();
    }
    return _qualityMetrics.where((m) => m.batchId == batchId).toList();
  }

  List<Certification> get activeCertifications {
    return _certifications.where((c) => c.active).toList();
  }
}


