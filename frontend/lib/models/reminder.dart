class Reminder {
  Reminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.dueDate,
    required this.isCompleted,
    this.mileageThreshold,
    this.notes,
  });

  final String id;
  final String vehicleId;
  final String title;
  final DateTime dueDate;
  final bool isCompleted;
  final int? mileageThreshold;
  final String? notes;

  Reminder copyWith({
    String? id,
    String? vehicleId,
    String? title,
    DateTime? dueDate,
    bool? isCompleted,
    int? mileageThreshold,
    String? notes,
  }) {
    return Reminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      mileageThreshold: mileageThreshold ?? this.mileageThreshold,
      notes: notes ?? this.notes,
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id']?.toString() ?? '',
      vehicleId:
          json['vehicle_id']?.toString() ?? json['vehicleId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      dueDate: DateTime.tryParse(
            json['due_date']?.toString() ??
                json['dueDate']?.toString() ??
                DateTime.now().toIso8601String(),
          ) ??
          DateTime.now(),
      isCompleted: json['is_completed'] == true || json['isCompleted'] == true,
      mileageThreshold: _parseNullableInt(
        json['mileage_threshold'] ?? json['mileageThreshold'],
      ),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'due_date': dueDate.toIso8601String(),
      'is_completed': isCompleted,
      'mileage_threshold': mileageThreshold,
      'notes': notes,
    };
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return null;
    }
    if (value is int) {
      return value;
    }
    return int.tryParse(value.toString());
  }
}

