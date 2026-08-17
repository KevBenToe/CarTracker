import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';
import 'package:vehicle_service_manager_frontend/services/demo_service.dart';

abstract class VehicleRepository {
  Future<List<Vehicle>> getVehicles();
  Future<Vehicle> getVehicle(String id);
  Future<Vehicle> createVehicle(Vehicle vehicle);
  Future<Vehicle> updateVehicle(Vehicle vehicle);
  Future<void> deleteVehicle(String id);
  Future<Vehicle> uploadImage(String vehicleId, List<int> imageBytes, String fileName);
}

class ApiVehicleRepository implements VehicleRepository {
  ApiVehicleRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<Vehicle>> getVehicles() async {
    final List<dynamic> data = await _apiService.getList('vehicles/');
    return data
        .whereType<Map>()
        .map((Map item) => Vehicle.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    final Map<String, dynamic> data = await _apiService.getObject('vehicles/$id/');
    return Vehicle.fromJson(data);
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    final Map<String, dynamic> data =
        await _apiService.postObject('vehicles/', vehicle.toJson());
    return Vehicle.fromJson(data);
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    final Map<String, dynamic> data =
        await _apiService.putObject('vehicles/${vehicle.id}/', vehicle.toJson());
    return Vehicle.fromJson(data);
  }

  @override
  Future<void> deleteVehicle(String id) {
    return _apiService.delete('vehicles/$id/');
  }

  @override
  Future<Vehicle> uploadImage(String vehicleId, List<int> imageBytes, String fileName) async {
    final Map<String, dynamic> data = await _apiService.patchMultipart(
      'vehicles/$vehicleId/',
      <String, String>{},
      imageBytes,
      fileName,
    );
    return Vehicle.fromJson(data);
  }
}

class DemoVehicleRepository implements VehicleRepository {
  DemoVehicleRepository({required DemoService demoService}) : _demoService = demoService;

  final DemoService _demoService;
  final List<Vehicle> _vehicles = <Vehicle>[];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final List<Map<String, dynamic>> data = await _demoService.loadCollection(
      'vehicles',
      DemoSeeds.vehicles(),
    );
    _vehicles
      ..clear()
      ..addAll(data.map(Vehicle.fromJson));
    _initialized = true;
  }

  Future<void> _persist() async {
    await _demoService.saveCollection(
      'vehicles',
      _vehicles.map((Vehicle vehicle) => vehicle.toJson()).toList(),
    );
  }

  @override
  Future<List<Vehicle>> getVehicles() async {
    await _ensureInitialized();
    return List<Vehicle>.from(_vehicles);
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    await _ensureInitialized();
    return _vehicles.firstWhere((Vehicle vehicle) => vehicle.id == id);
  }

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    await _ensureInitialized();
    _vehicles.add(vehicle);
    await _persist();
    return vehicle;
  }

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async {
    await _ensureInitialized();
    final int index =
        _vehicles.indexWhere((Vehicle item) => item.id == vehicle.id);
    if (index == -1) {
      throw StateError('Vehicle ${vehicle.id} not found.');
    }
    _vehicles[index] = vehicle;
    await _persist();
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    await _ensureInitialized();
    _vehicles.removeWhere((Vehicle vehicle) => vehicle.id == id);
    await _persist();
  }

  @override
  Future<Vehicle> uploadImage(String vehicleId, List<int> imageBytes, String fileName) async {
    // In demo mode, image upload is not persisted; return vehicle unchanged.
    await _ensureInitialized();
    return _vehicles.firstWhere((Vehicle v) => v.id == vehicleId);
  }
}

