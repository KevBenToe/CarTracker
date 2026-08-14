class Vehicle {
  Vehicle({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.licensePlate,
    required this.vin,
    required this.mileage,
    this.nickname,
    this.notes,
    this.lastServiceDate,
    this.nextServiceDate,
  });

  final String id;
  final String make;
  final String model;
  final int year;
  final String licensePlate;
  final String vin;
  final int mileage;
  final String? nickname;
  final String? notes;
  final DateTime? lastServiceDate;
  final DateTime? nextServiceDate;

  String get displayName {
    if (nickname != null && nickname!.trim().isNotEmpty) {
      return nickname!;
    }
    return '$year $make $model';
  }

  Vehicle copyWith({
    String? id,
    String? make,
    String? model,
    int? year,
    String? licensePlate,
    String? vin,
    int? mileage,
    String? nickname,
    String? notes,
    DateTime? lastServiceDate,
    DateTime? nextServiceDate,
    bool clearLastServiceDate = false,
    bool clearNextServiceDate = false,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      licensePlate: licensePlate ?? this.licensePlate,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      nickname: nickname ?? this.nickname,
      notes: notes ?? this.notes,
      lastServiceDate:
          clearLastServiceDate ? null : lastServiceDate ?? this.lastServiceDate,
      nextServiceDate:
          clearNextServiceDate ? null : nextServiceDate ?? this.nextServiceDate,
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      make: json['make']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: _parseInt(json['year']),
      licensePlate: json['license_plate']?.toString() ??
          json['licensePlate']?.toString() ??
          '',
      vin: json['vin']?.toString() ?? '',
      mileage: _parseInt(json['mileage']),
      nickname: json['nickname']?.toString(),
      notes: json['notes']?.toString(),
      lastServiceDate: _parseDate(
        json['last_service_date'] ?? json['lastServiceDate'],
      ),
      nextServiceDate: _parseDate(
        json['next_service_date'] ?? json['nextServiceDate'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'license_plate': licensePlate,
      'vin': vin,
      'mileage': mileage,
      'nickname': nickname,
      'notes': notes,
      'last_service_date': lastServiceDate?.toIso8601String(),
      'next_service_date': nextServiceDate?.toIso8601String(),
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}

