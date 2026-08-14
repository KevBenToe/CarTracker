class VehicleDocument {
  VehicleDocument({
    required this.id,
    required this.vehicleId,
    required this.name,
    required this.type,
    required this.issuedDate,
    this.expiryDate,
    this.number,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final String name;
  final String type;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String? number;
  final String? notes;

  factory VehicleDocument.fromJson(Map<String, dynamic> json) {
    return VehicleDocument(
      id: json['id']?.toString() ?? '',
      vehicleId:
          json['vehicle_id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      issuedDate: DateTime.tryParse(
            json['issued_date']?.toString() ??
                json['issuedDate']?.toString() ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      expiryDate: _parseDate(json['expiry_date'] ?? json['expiryDate']),
      number: json['number']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vehicle_id': vehicleId,
      'name': name,
      'type': type,
      'issued_date': issuedDate.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'number': number,
      'notes': notes,
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

