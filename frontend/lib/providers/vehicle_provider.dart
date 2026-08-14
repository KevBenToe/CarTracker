import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/repositories/vehicle_repository.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider({required VehicleRepository repository}) : _repository = repository {
    unawaited(loadVehicles());
  }

  VehicleRepository _repository;
  List<Vehicle> _vehicles = <Vehicle>[];
  bool _isLoading = false;
  String? _errorMessage;

  List<Vehicle> get vehicles => _vehicles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateRepository(VehicleRepository repository) {
    if (identical(_repository, repository)) {
      return;
    }
    _repository = repository;
    unawaited(loadVehicles());
  }

  Future<void> loadVehicles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _vehicles = await _repository.getVehicles();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Vehicle? findById(String id) {
    for (final Vehicle vehicle in _vehicles) {
      if (vehicle.id == id) {
        return vehicle;
      }
    }
    return null;
  }

  Future<Vehicle?> fetchVehicle(String id) async {
    final Vehicle? cached = findById(id);
    if (cached != null) {
      return cached;
    }

    try {
      return await _repository.getVehicle(id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveVehicle(Vehicle vehicle) async {
    final bool exists = findById(vehicle.id) != null;
    if (exists) {
      await _repository.updateVehicle(vehicle);
    } else {
      await _repository.createVehicle(vehicle);
    }
    await loadVehicles();
  }

  Future<void> deleteVehicle(String id) async {
    await _repository.deleteVehicle(id);
    _vehicles = _vehicles.where((Vehicle vehicle) => vehicle.id != id).toList();
    notifyListeners();
  }
}

