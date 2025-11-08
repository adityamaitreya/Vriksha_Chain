import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/batch_provider.dart';
import '../providers/auth_provider.dart';
import '../models/batch_model.dart';
import '../models/nfc_authentication_model.dart';
import '../services/nfc_service.dart';
import '../services/database_service.dart';
import 'package:intl/intl.dart';

class CreateBatchDialog extends StatefulWidget {
  const CreateBatchDialog({super.key});

  @override
  State<CreateBatchDialog> createState() => _CreateBatchDialogState();
}

class _CreateBatchDialogState extends State<CreateBatchDialog> {
  final _formKey = GlobalKey<FormState>();
  final _batchNumberController = TextEditingController();
  final _productNameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _originController = TextEditingController();
  final _locationController = TextEditingController();
  
  DateTime? _harvestDate;
  String _status = 'Created';
  String _quality = 'Standard';
  bool _isLoading = false;
  String? _nfcTagId;
  bool _isReadingNFC = false;
  final NFCService _nfcService = NFCService();
  final DatabaseService _databaseService = DatabaseService();

  @override
  void dispose() {
    _batchNumberController.dispose();
    _productNameController.dispose();
    _quantityController.dispose();
    _originController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _harvestDate) {
      setState(() {
        _harvestDate = picked;
      });
    }
  }

  Future<void> _readNFCTag() async {
    try {
      setState(() => _isReadingNFC = true);

      // Check if NFC is available
      final isAvailable = await _nfcService.isNFCAvailable();
      if (!isAvailable) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NFC is not available on this device'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        setState(() => _isReadingNFC = false);
        return;
      }

      // Show dialog with instructions
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Scan NFC Tag'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Please hold your device near the NFC tag...'),
              ],
            ),
          ),
        );
      }

      // Read NFC tag
      final tagId = await _nfcService.readNFCTag();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (tagId != null && tagId.isNotEmpty) {
          setState(() {
            _nfcTagId = tagId;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('NFC Tag read successfully: ${tagId.substring(0, tagId.length > 20 ? 20 : tagId.length)}...'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to read NFC tag. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading NFC tag: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isReadingNFC = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Generate batch number if not provided
    String batchNumber = _batchNumberController.text.trim();
    if (batchNumber.isEmpty) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final cleanProductName = _productNameController.text
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
          .toUpperCase()
          .substring(0, _productNameController.text.length > 8 ? 8 : _productNameController.text.length);
      batchNumber = '${cleanProductName.isEmpty ? 'BATCH' : cleanProductName}-$timestamp';
    }

    // Validate NFC tag is read (required at harvest)
    if (_nfcTagId == null || _nfcTagId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please scan an NFC tag before creating the batch.'),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() => _isLoading = false);
      return;
    }

    final batch = Batch(
      id: '', // Will be set by Firebase
      batchNumber: batchNumber,
      productName: _productNameController.text.trim(),
      quantity: _quantityController.text.trim(),
      origin: _originController.text.trim(),
      harvestDate: _harvestDate != null
          ? DateFormat('yyyy-MM-dd').format(_harvestDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      status: _status,
      quality: _quality,
      currentLocation: _locationController.text.trim(),
      lastUpdated: DateTime.now().toIso8601String(),
      nfcTagId: _nfcTagId!,
    );

    final batchProvider = Provider.of<BatchProvider>(context, listen: false);
    final batchId = await batchProvider.createBatch(batch);

    setState(() => _isLoading = false);

    if (batchId != null && mounted) {
      // Create NFC authentication record for harvest step
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final authenticatedBy = authProvider.user?.email ?? authProvider.user?.uid ?? 'Unknown';
      
      final nfcAuth = NFCAuthentication(
        id: '',
        batchId: batchId,
        nfcTagId: _nfcTagId!,
        step: 'Harvest',
        location: _locationController.text.trim().isNotEmpty 
            ? _locationController.text.trim() 
            : _originController.text.trim(),
        authenticatedBy: authenticatedBy,
        timestamp: DateTime.now().toIso8601String(),
        isValid: true,
        notes: 'NFC tag registered at harvest time',
      );

      await _databaseService.createNFCAuthentication(nfcAuth);

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Batch created successfully with NFC tag!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create batch. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Create New Batch',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _batchNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Batch Number (auto-generated if empty)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _productNameController,
                        decoration: const InputDecoration(
                          labelText: 'Product Name *',
                          hintText: 'e.g., Ashwagandha Root Powder',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.eco),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter product name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity *',
                                hintText: 'e.g., 500kg',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.scale),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Harvest Date *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _harvestDate != null
                                      ? DateFormat('yyyy-MM-dd').format(_harvestDate!)
                                      : 'Select date',
                                  style: TextStyle(
                                    color: _harvestDate != null
                                        ? Colors.black
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _originController,
                        decoration: const InputDecoration(
                          labelText: 'Origin *',
                          hintText: 'e.g., Rajasthan, India',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter origin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.info),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Created', child: Text('Created')),
                                DropdownMenuItem(value: 'Harvested', child: Text('Harvested')),
                                DropdownMenuItem(value: 'Processing', child: Text('Processing')),
                                DropdownMenuItem(value: 'Quality Check', child: Text('Quality Check')),
                                DropdownMenuItem(value: 'Packaged', child: Text('Packaged')),
                                DropdownMenuItem(value: 'In Transit', child: Text('In Transit')),
                                DropdownMenuItem(value: 'In Distribution', child: Text('In Distribution')),
                                DropdownMenuItem(value: 'Delivered', child: Text('Delivered')),
                                DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _status = value);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _quality,
                              decoration: const InputDecoration(
                                labelText: 'Quality *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.star),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Premium', child: Text('Premium')),
                                DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                                DropdownMenuItem(value: 'Unknown', child: Text('Unknown')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _quality = value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Current Location',
                          hintText: 'e.g., Distribution Center, Mumbai',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.place),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // NFC Tag Section
                      Card(
                        color: Colors.blue[50],
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.nfc, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'NFC Tag (Required at Harvest)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (_nfcTagId != null && _nfcTagId!.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'NFC Tag Registered',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                            Text(
                                              'ID: ${_nfcTagId!.length > 30 ? "${_nfcTagId!.substring(0, 30)}..." : _nfcTagId!}',
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.refresh),
                                        onPressed: _isReadingNFC ? null : _readNFCTag,
                                        tooltip: 'Rescan NFC Tag',
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ElevatedButton.icon(
                                  onPressed: _isReadingNFC ? null : _readNFCTag,
                                  icon: _isReadingNFC
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.nfc),
                                  label: Text(_isReadingNFC ? 'Reading...' : 'Scan NFC Tag'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                'Hold your device near the NFC tag to register it at harvest time.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Create Batch'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


