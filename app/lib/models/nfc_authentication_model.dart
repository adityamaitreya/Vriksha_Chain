class NFCAuthentication {
  final String id;
  final String batchId;
  final String nfcTagId;
  final String step; // e.g., 'Harvest', 'Processing', 'Quality Check', 'Packaging', 'Transit', etc.
  final String location;
  final String authenticatedBy; // User ID or name
  final String timestamp;
  final bool isValid; // Whether the NFC tag was valid for this batch
  final String? notes;

  NFCAuthentication({
    required this.id,
    required this.batchId,
    required this.nfcTagId,
    required this.step,
    required this.location,
    required this.authenticatedBy,
    required this.timestamp,
    this.isValid = true,
    this.notes,
  });

  // Convert from Firebase JSON
  factory NFCAuthentication.fromJson(Map<String, dynamic> json, String id) {
    return NFCAuthentication(
      id: id,
      batchId: json['batchId'] ?? '',
      nfcTagId: json['nfcTagId'] ?? '',
      step: json['step'] ?? '',
      location: json['location'] ?? '',
      authenticatedBy: json['authenticatedBy'] ?? '',
      timestamp: json['timestamp'] ?? '',
      isValid: json['isValid'] ?? true,
      notes: json['notes'],
    );
  }

  // Convert to Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'batchId': batchId,
      'nfcTagId': nfcTagId,
      'step': step,
      'location': location,
      'authenticatedBy': authenticatedBy,
      'timestamp': timestamp,
      'isValid': isValid,
      'notes': notes,
    };
  }

  NFCAuthentication copyWith({
    String? id,
    String? batchId,
    String? nfcTagId,
    String? step,
    String? location,
    String? authenticatedBy,
    String? timestamp,
    bool? isValid,
    String? notes,
  }) {
    return NFCAuthentication(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      nfcTagId: nfcTagId ?? this.nfcTagId,
      step: step ?? this.step,
      location: location ?? this.location,
      authenticatedBy: authenticatedBy ?? this.authenticatedBy,
      timestamp: timestamp ?? this.timestamp,
      isValid: isValid ?? this.isValid,
      notes: notes ?? this.notes,
    );
  }
}

