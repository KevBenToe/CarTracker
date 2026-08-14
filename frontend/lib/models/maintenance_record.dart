class MaintenanceRecord {
  MaintenanceRecord({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.serviceType,
    required this.date,
    required this.mileage,
    required this.cost,
    required this.status,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final String title;
  final String serviceType;
  final DateTime date;
  final int mileage;
  final double cost;
  final String status;
  final String? notes;

  MaintenanceRecord copyWith({
    String? id,
    String? vehicleId,
    String? title,
    String? serviceType,
    DateTime? date,
    int? mileage,
    double? cost,
    String? status,
    String? notes,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      cost: cost ?? this.cost,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  factory MaintenanceRecord.fromJson(Map<String, dynamic> json) {
    return MaintenanceRecord(
      id: json['id']?.toString() ?? '',
      vehicleId:
          json['vehicle_id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      serviceType:
          json['service_type']?.toString() ?? json['serviceType']?.toString() ?? '',
      date: DateTime.tryParse(
            json['date']?.toString() ?? DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      mileage: _parseInt(json['mileage']),
      cost: _parseDouble(json['cost']),
      status: json['status']?.toString() ?? 'Completed',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'service_type': serviceType,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'cost': cost,
      'status': status,
      'notes': notes,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

