import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';
import 'package:vehicle_service_manager_frontend/services/demo_service.dart';

abstract class MaintenanceRepository {
  Future<List<MaintenanceRecord>> getRecords();
  Future<List<MaintenanceRecord>> getRecordsForVehicle(String vehicleId);
  Future<MaintenanceRecord> getRecord(String id);
  Future<MaintenanceRecord> createRecord(MaintenanceRecord record);
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record);
  Future<void> deleteRecord(String id);
}

class ApiMaintenanceRepository implements MaintenanceRepository {
  ApiMaintenanceRepository({required ApiService apiService})
      : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<MaintenanceRecord>> getRecords() async {
    final List<dynamic> data = await _apiService.getList('maintenance-records/');
    return data
        .whereType<Map>()
        .map(
          (Map item) =>
              MaintenanceRecord.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsForVehicle(String vehicleId) async {
    final List<MaintenanceRecord> all = await getRecords();
    return all
        .where((MaintenanceRecord record) => record.vehicleId == vehicleId)
        .toList();
  }

  @override
  Future<MaintenanceRecord> getRecord(String id) async {
    final Map<String, dynamic> data =
        await _apiService.getObject('maintenance-records/$id/');
    return MaintenanceRecord.fromJson(data);
  }

  @override
  Future<MaintenanceRecord> createRecord(MaintenanceRecord record) async {
    final Map<String, dynamic> data =
        await _apiService.postObject('maintenance-records/', record.toJson());
    return MaintenanceRecord.fromJson(data);
  }

  @override
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record) async {
    final Map<String, dynamic> data = await _apiService.putObject(
      'maintenance-records/${record.id}/',
      record.toJson(),
    );
    return MaintenanceRecord.fromJson(data);
  }

  @override
  Future<void> deleteRecord(String id) {
    return _apiService.delete('maintenance-records/$id/');
  }
}

class DemoMaintenanceRepository implements MaintenanceRepository {
  DemoMaintenanceRepository({required DemoService demoService})
      : _demoService = demoService;

  final DemoService _demoService;
  final List<MaintenanceRecord> _records = <MaintenanceRecord>[];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final List<Map<String, dynamic>> data = await _demoService.loadCollection(
      'maintenance',
      DemoSeeds.maintenance(),
    );
    _records
      ..clear()
      ..addAll(data.map(MaintenanceRecord.fromJson));
    _initialized = true;
  }

  Future<void> _persist() async {
    await _demoService.saveCollection(
      'maintenance',
      _records.map((MaintenanceRecord record) => record.toJson()).toList(),
    );
  }

  @override
  Future<List<MaintenanceRecord>> getRecords() async {
    await _ensureInitialized();
    final List<MaintenanceRecord> values = List<MaintenanceRecord>.from(_records);
    values.sort((MaintenanceRecord a, MaintenanceRecord b) => b.date.compareTo(a.date));
    return values;
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsForVehicle(String vehicleId) async {
    final List<MaintenanceRecord> all = await getRecords();
    return all
        .where((MaintenanceRecord record) => record.vehicleId == vehicleId)
        .toList();
  }

  @override
  Future<MaintenanceRecord> getRecord(String id) async {
    await _ensureInitialized();
    return _records.firstWhere((MaintenanceRecord record) => record.id == id);
  }

  @override
  Future<MaintenanceRecord> createRecord(MaintenanceRecord record) async {
    await _ensureInitialized();
    _records.add(record);
    await _persist();
    return record;
  }

  @override
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record) async {
    await _ensureInitialized();
    final int index = _records.indexWhere(
      (MaintenanceRecord item) => item.id == record.id,
    );
    if (index == -1) {
      throw StateError('Record ${record.id} not found.');
    }
    _records[index] = record;
    await _persist();
    return record;
  }

  @override
  Future<void> deleteRecord(String id) async {
    await _ensureInitialized();
    _records.removeWhere((MaintenanceRecord record) => record.id == id);
    await _persist();
  }
}

