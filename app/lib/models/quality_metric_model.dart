class QualityMetric {
  final String id;
  final String? batchId;
  final String? productName;
  final String category;
  final int score;
  final String status;
  final String? notes;
  final String lastUpdated;

  QualityMetric({
    required this.id,
    this.batchId,
    this.productName,
    required this.category,
    required this.score,
    required this.status,
    this.notes,
    required this.lastUpdated,
  });

  factory QualityMetric.fromJson(Map<String, dynamic> json, String id) {
    return QualityMetric(
      id: id,
      batchId: json['batchId'],
      productName: json['productName'],
      category: json['category'] ?? '',
      score: json['score'] ?? 0,
      status: json['status'] ?? '',
      notes: json['notes'],
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (batchId != null) 'batchId': batchId,
      if (productName != null) 'productName': productName,
      'category': category,
      'score': score,
      'status': status,
      if (notes != null) 'notes': notes,
      'lastUpdated': lastUpdated,
    };
  }
}

class Certification {
  final String id;
  final String name;
  final bool active;
  final String? issuedDate;
  final String? expiryDate;
  final String? issuingBody;
  final String? certificateNumber;
  final String lastUpdated;

  Certification({
    required this.id,
    required this.name,
    required this.active,
    this.issuedDate,
    this.expiryDate,
    this.issuingBody,
    this.certificateNumber,
    required this.lastUpdated,
  });

  factory Certification.fromJson(Map<String, dynamic> json, String id) {
    return Certification(
      id: id,
      name: json['name'] ?? '',
      active: json['active'] ?? false,
      issuedDate: json['issuedDate'],
      expiryDate: json['expiryDate'],
      issuingBody: json['issuingBody'],
      certificateNumber: json['certificateNumber'],
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'active': active,
      if (issuedDate != null) 'issuedDate': issuedDate,
      if (expiryDate != null) 'expiryDate': expiryDate,
      if (issuingBody != null) 'issuingBody': issuingBody,
      if (certificateNumber != null) 'certificateNumber': certificateNumber,
      'lastUpdated': lastUpdated,
    };
  }
}


