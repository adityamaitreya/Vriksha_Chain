class Batch {
  final String id;
  final String batchNumber;
  final String productName;
  final String quantity;
  final String origin;
  final String harvestDate;
  final String status;
  final String quality;
  final String currentLocation;
  final String lastUpdated;
  final String nfcTagId; // NFC tag ID registered at harvest

  Batch({
    required this.id,
    required this.batchNumber,
    required this.productName,
    required this.quantity,
    required this.origin,
    required this.harvestDate,
    required this.status,
    required this.quality,
    required this.currentLocation,
    required this.lastUpdated,
    this.nfcTagId = '',
  });

  // Convert from Firebase JSON
  factory Batch.fromJson(Map<String, dynamic> json, String id) {
    return Batch(
      id: id,
      batchNumber: json['batchNumber'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? '',
      origin: json['origin'] ?? '',
      harvestDate: json['harvestDate'] ?? '',
      status: json['status'] ?? '',
      quality: json['quality'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      nfcTagId: json['nfcTagId'] ?? '',
    );
  }

  // Convert to Firebase JSON
  Map<String, dynamic> toJson() {
    return {
      'batchNumber': batchNumber,
      'productName': productName,
      'quantity': quantity,
      'origin': origin,
      'harvestDate': harvestDate,
      'status': status,
      'quality': quality,
      'currentLocation': currentLocation,
      'lastUpdated': lastUpdated,
      'nfcTagId': nfcTagId,
    };
  }

  Batch copyWith({
    String? batchNumber,
    String? productName,
    String? quantity,
    String? origin,
    String? harvestDate,
    String? status,
    String? quality,
    String? currentLocation,
    String? lastUpdated,
    String? nfcTagId,
  }) {
    return Batch(
      id: id,
      batchNumber: batchNumber ?? this.batchNumber,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      origin: origin ?? this.origin,
      harvestDate: harvestDate ?? this.harvestDate,
      status: status ?? this.status,
      quality: quality ?? this.quality,
      currentLocation: currentLocation ?? this.currentLocation,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      nfcTagId: nfcTagId ?? this.nfcTagId,
    );
  }
}


