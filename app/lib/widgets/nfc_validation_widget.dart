import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/batch_model.dart';
import '../models/nfc_authentication_model.dart';
import '../services/nfc_service.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';

class NFCValidationWidget extends StatefulWidget {
  final Batch batch;
  final String step; // Supply chain step: 'Processing', 'Quality Check', 'Packaging', etc.
  final VoidCallback? onValidationSuccess;

  const NFCValidationWidget({
    super.key,
    required this.batch,
    required this.step,
    this.onValidationSuccess,
  });

  @override
  State<NFCValidationWidget> createState() => _NFCValidationWidgetState();
}

class _NFCValidationWidgetState extends State<NFCValidationWidget> {
  final NFCService _nfcService = NFCService();
  final DatabaseService _databaseService = DatabaseService();
  bool _isValidating = false;
  bool? _lastValidationResult;
  String? _lastScannedTagId;

  Future<void> _validateNFCTag() async {
    try {
      setState(() {
        _isValidating = true;
        _lastValidationResult = null;
      });

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
        setState(() => _isValidating = false);
        return;
      }

      // Show dialog with instructions
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text('Validate NFC Tag - ${widget.step}'),
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
      final scannedTagId = await _nfcService.readNFCTag();

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        if (scannedTagId == null || scannedTagId.isEmpty) {
          setState(() {
            _isValidating = false;
            _lastValidationResult = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to read NFC tag. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate the scanned tag against the batch's registered NFC tag
        final isValid = await _nfcService.validateNFCTag(
          scannedTagId,
          widget.batch.id,
          widget.batch.nfcTagId,
        );

        setState(() {
          _lastScannedTagId = scannedTagId;
          _lastValidationResult = isValid;
          _isValidating = false;
        });

        // Create NFC authentication record
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final authenticatedBy = authProvider.user?.email ?? 
                                authProvider.user?.uid ?? 
                                'Unknown';

        final nfcAuth = NFCAuthentication(
          id: '',
          batchId: widget.batch.id,
          nfcTagId: scannedTagId,
          step: widget.step,
          location: widget.batch.currentLocation.isNotEmpty
              ? widget.batch.currentLocation
              : widget.batch.origin,
          authenticatedBy: authenticatedBy,
          timestamp: DateTime.now().toIso8601String(),
          isValid: isValid,
          notes: isValid 
              ? 'NFC tag validated successfully at ${widget.step} step'
              : 'NFC tag mismatch - scanned tag does not match registered tag',
        );

        await _databaseService.createNFCAuthentication(nfcAuth);

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NFC Tag validated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Call success callback if provided
          if (widget.onValidationSuccess != null) {
            widget.onValidationSuccess!();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NFC Tag validation failed! Tag does not match this batch.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog if still open
        setState(() {
          _isValidating = false;
          _lastValidationResult = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error validating NFC tag: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.nfc,
                  color: Colors.blue[700],
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NFC Validation - ${widget.step}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.batch.nfcTagId.isNotEmpty)
                        Text(
                          'Registered Tag: ${widget.batch.nfcTagId.length > 20 ? "${widget.batch.nfcTagId.substring(0, 20)}..." : widget.batch.nfcTagId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Validation result display
            if (_lastValidationResult != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _lastValidationResult == true 
                      ? Colors.green[50] 
                      : Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _lastValidationResult == true 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _lastValidationResult == true 
                          ? Icons.check_circle 
                          : Icons.error,
                      color: _lastValidationResult == true 
                          ? Colors.green 
                          : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _lastValidationResult == true 
                                ? 'Validation Successful' 
                                : 'Validation Failed',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _lastValidationResult == true 
                                  ? Colors.green[700] 
                                  : Colors.red[700],
                            ),
                          ),
                          if (_lastScannedTagId != null)
                            Text(
                              'Scanned: ${_lastScannedTagId!.length > 25 ? "${_lastScannedTagId!.substring(0, 25)}..." : _lastScannedTagId!}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Validate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isValidating ? null : _validateNFCTag,
                icon: _isValidating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.nfc),
                label: Text(_isValidating ? 'Validating...' : 'Validate NFC Tag'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Scan the NFC tag to authenticate this batch at the ${widget.step} step.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

