import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/repositories/maintenance_repository.dart';

class MaintenanceProvider extends ChangeNotifier {
  MaintenanceProvider({required MaintenanceRepository repository})
      : _repository = repository {
    unawaited(loadRecords());
  }

  MaintenanceRepository _repository;
  List<MaintenanceRecord> _records = <MaintenanceRecord>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<MaintenanceRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateRepository(MaintenanceRepository repository) {
    if (identical(_repository, repository)) {
      return;
    }
    _repository = repository;
    unawaited(loadRecords());
  }

  Future<void> loadRecords() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _records = await _repository.getRecords();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  MaintenanceRecord? findById(String id) {
    for (final MaintenanceRecord record in _records) {
      if (record.id == id) {
        return record;
      }
    }
    return null;
  }

  List<MaintenanceRecord> recordsForVehicle(String vehicleId) {
    return _records
        .where((MaintenanceRecord record) => record.vehicleId == vehicleId)
        .toList();
  }

  Future<void> saveRecord(MaintenanceRecord record) async {
    final bool exists = findById(record.id) != null;
    if (exists) {
      await _repository.updateRecord(record);
    } else {
      await _repository.createRecord(record);
    }
    await loadRecords();
  }

  Future<void> deleteRecord(String id) async {
    await _repository.deleteRecord(id);
    _records = _records.where((MaintenanceRecord record) => record.id != id).toList();
    notifyListeners();
  }
}
