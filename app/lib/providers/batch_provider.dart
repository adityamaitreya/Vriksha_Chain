import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/batch_model.dart';
import '../services/database_service.dart';

class BatchProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  List<Batch> _batches = [];
  Batch? _selectedBatch;
  bool _isLoading = true;
  String? _error;

  List<Batch> get batches => _batches;
  Batch? get selectedBatch => _selectedBatch;
  bool get isLoading => _isLoading;
  String? get error => _error;

  BatchProvider() {
    _initBatchesStream();
  }

  void _initBatchesStream() {
    _databaseService.getBatchesStream().listen((DatabaseEvent event) {
      try {
        if (event.snapshot.value == null) {
          _batches = [];
        } else {
          final Map<dynamic, dynamic> data = 
              event.snapshot.value as Map<dynamic, dynamic>;
          
          _batches = data.entries.map((entry) {
            return Batch.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
              entry.key as String,
            );
          }).toList();
        }
        _error = null;
        _isLoading = false;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<String?> createBatch(Batch batch) async {
    return await _databaseService.createBatch(batch);
  }

  Future<bool> updateBatch(String id, Map<String, dynamic> updates) async {
    final success = await _databaseService.updateBatch(id, updates);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  Future<bool> deleteBatch(String id) async {
    final success = await _databaseService.deleteBatch(id);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  void selectBatch(Batch? batch) {
    _selectedBatch = batch;
    notifyListeners();
  }

  // Get batches by status
  List<Batch> getBatchesByStatus(String status) {
    return _batches.where((b) => b.status == status).toList();
  }

  // Get active batches
  List<Batch> get activeBatches {
    return _batches.where((b) => 
      !['Delivered', 'Completed', 'Cancelled'].contains(b.status)
    ).toList();
  }
}


