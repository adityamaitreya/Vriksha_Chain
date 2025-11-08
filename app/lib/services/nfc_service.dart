import 'package:nfc_manager/nfc_manager.dart';

class NFCService {
  // Check if NFC is available on the device
  Future<bool> isNFCAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // Start NFC session for reading tag
  Future<String?> readNFCTag() async {
    try {
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      String? tagId;

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          // Extract tag ID from the tag
          tagId = _extractTagId(tag);
          await NfcManager.instance.stopSession();
        },
      );

      return tagId;
    } catch (e) {
      print('Error reading NFC tag: $e');
      rethrow;
    }
  }

  // Write data to NFC tag
  Future<bool> writeNFCTag(String data) async {
    try {
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      bool success = false;

      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Get NDEF adapter if available
            final ndef = Ndef.from(tag);
            if (ndef != null) {
              final ndefMessage = NdefMessage([
                NdefRecord.createText(data),
              ]);
              await ndef.write(ndefMessage);
              success = true;
            } else {
              throw Exception('Tag does not support NDEF');
            }
          } catch (e) {
            print('Error writing to NFC tag: $e');
          } finally {
            await NfcManager.instance.stopSession();
          }
        },
      );

      return success;
    } catch (e) {
      print('Error writing NFC tag: $e');
      rethrow;
    }
  }

  // Stop NFC session
  Future<void> stopSession() async {
    await NfcManager.instance.stopSession();
  }

  // Extract tag ID from NFC tag
  String _extractTagId(NfcTag tag) {
    // Try to get ID from tag data - nfc_manager stores identifier in data
    // The identifier is typically under 'identifier' or 'id' key
    try {
      // Method 1: Check for identifier in tag data
      if (tag.data.containsKey('identifier')) {
        final identifier = tag.data['identifier'];
        if (identifier is List<int> && identifier.isNotEmpty) {
          return identifier.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
        }
      }
      
      // Method 2: Check for id in tag data
      if (tag.data.containsKey('id')) {
        final id = tag.data['id'];
        if (id is List<int> && id.isNotEmpty) {
          return id.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
        }
        if (id is String && id.isNotEmpty) {
          return id;
        }
      }
      
      // Method 3: Use handle if available
      if (tag.handle != null && tag.handle!.isNotEmpty) {
        // handle is a String representing the tag handle, just return it
        return tag.handle!;
      }
      
      // Method 4: Try to extract from ISO15693
      if (tag.data.containsKey('iso15693')) {
        final iso15693 = tag.data['iso15693'];
        if (iso15693 is Map && iso15693.containsKey('identifier')) {
          final identifier = iso15693['identifier'];
          if (identifier is List<int> && identifier.isNotEmpty) {
            return identifier.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
          }
        }
      }
      
      // Method 5: Try to extract from ISO14443
      if (tag.data.containsKey('iso14443')) {
        final iso14443 = tag.data['iso14443'];
        if (iso14443 is Map && iso14443.containsKey('identifier')) {
          final identifier = iso14443['identifier'];
          if (identifier is List<int> && identifier.isNotEmpty) {
            return identifier.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
          }
        }
      }
      
      // Fallback: Create a unique ID from tag data
      final dataString = tag.data.toString();
      return dataString.hashCode.toRadixString(16);
    } catch (e) {
      print('Error extracting tag ID: $e');
      // Final fallback
      return tag.data.hashCode.toString();
    }
  }

  // Validate NFC tag ID against batch
  Future<bool> validateNFCTag(String nfcTagId, String expectedBatchId, String batchNfcTagId) async {
    // Check if the scanned NFC tag ID matches the batch's registered NFC tag ID
    return nfcTagId == batchNfcTagId;
  }
}

