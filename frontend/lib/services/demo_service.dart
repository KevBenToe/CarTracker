import 'package:idb_shim/idb.dart';
import 'package:idb_shim/idb_browser.dart';

const String demoVehicleId1 = 'veh-subaru-outback';
const String demoVehicleId2 = 'veh-tesla-model3';
const String demoVehicleId3 = 'veh-ford-transit';

class DemoSeeds {
  static List<Map<String, dynamic>> vehicles() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': demoVehicleId1,
        'make': 'Subaru',
        'model': 'Outback',
        'year': 2021,
        'license_plate': 'ATL-2481',
        'vin': '4S4BTANC9M3123456',
        'mileage': 42850,
        'nickname': 'Family Wagon',
        'notes': 'AWD family vehicle with roof rack.',
        'last_service_date': DateTime.now()
            .subtract(const Duration(days: 92))
            .toIso8601String(),
        'next_service_date': DateTime.now()
            .add(const Duration(days: 35))
            .toIso8601String(),
      },
      <String, dynamic>{
        'id': demoVehicleId2,
        'make': 'Tesla',
        'model': 'Model 3',
        'year': 2023,
        'license_plate': 'EV-2026',
        'vin': '5YJ3E1EA7PF987654',
        'mileage': 15720,
        'nickname': 'Daily EV',
        'notes': 'Rotate tires every 10k miles.',
        'last_service_date': DateTime.now()
            .subtract(const Duration(days: 44))
            .toIso8601String(),
        'next_service_date': DateTime.now()
            .add(const Duration(days: 80))
            .toIso8601String(),
      },
      <String, dynamic>{
        'id': demoVehicleId3,
        'make': 'Ford',
        'model': 'Transit',
        'year': 2020,
        'license_plate': 'VAN-901',
        'vin': '1FTBR1Y84LKA54321',
        'mileage': 88310,
        'nickname': 'Service Van',
        'notes': 'Fleet van used for parts and equipment.',
        'last_service_date': DateTime.now()
            .subtract(const Duration(days: 18))
            .toIso8601String(),
        'next_service_date': DateTime.now()
            .add(const Duration(days: 20))
            .toIso8601String(),
      },
    ];
  }

  static List<Map<String, dynamic>> maintenance() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'mnt-1001',
        'vehicle_id': demoVehicleId1,
        'title': 'Oil & filter change',
        'service_type': 'Routine Service',
        'date': DateTime.now()
            .subtract(const Duration(days: 92))
            .toIso8601String(),
        'mileage': 40320,
        'cost': 89.5,
        'status': 'Completed',
        'notes': 'Synthetic oil and cabin filter replacement.',
      },
      <String, dynamic>{
        'id': 'mnt-1002',
        'vehicle_id': demoVehicleId2,
        'title': 'Tire rotation',
        'service_type': 'Tires',
        'date': DateTime.now()
            .subtract(const Duration(days: 44))
            .toIso8601String(),
        'mileage': 12400,
        'cost': 45.0,
        'status': 'Completed',
        'notes': 'Inspected tread depth, all good.',
      },
      <String, dynamic>{
        'id': 'mnt-1003',
        'vehicle_id': demoVehicleId3,
        'title': 'Brake inspection',
        'service_type': 'Brakes',
        'date': DateTime.now()
            .add(const Duration(days: 10))
            .toIso8601String(),
        'mileage': 89000,
        'cost': 220.0,
        'status': 'Scheduled',
        'notes': 'Inspect front pads and rear rotors.',
      },
    ];
  }

  static List<Map<String, dynamic>> documents() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'doc-2001',
        'vehicle_id': demoVehicleId1,
        'name': 'Insurance Card',
        'type': 'Insurance',
        'issued_date': DateTime.now()
            .subtract(const Duration(days: 180))
            .toIso8601String(),
        'expiry_date': DateTime.now()
            .add(const Duration(days: 185))
            .toIso8601String(),
        'number': 'POL-44781',
        'notes': 'Digital copy available offline.',
      },
      <String, dynamic>{
        'id': 'doc-2002',
        'vehicle_id': demoVehicleId2,
        'name': 'Registration',
        'type': 'Registration',
        'issued_date': DateTime.now()
            .subtract(const Duration(days: 140))
            .toIso8601String(),
        'expiry_date': DateTime.now()
            .add(const Duration(days: 220))
            .toIso8601String(),
        'number': 'REG-99210',
        'notes': 'Renew online before due date.',
      },
      <String, dynamic>{
        'id': 'doc-2003',
        'vehicle_id': demoVehicleId3,
        'name': 'Fleet Permit',
        'type': 'Permit',
        'issued_date': DateTime.now()
            .subtract(const Duration(days: 300))
            .toIso8601String(),
        'expiry_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'number': 'FLT-1007',
        'notes': 'Expires next month.',
      },
    ];
  }

  static List<Map<String, dynamic>> reminders() {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'rem-3001',
        'vehicle_id': demoVehicleId1,
        'title': 'Schedule next oil change',
        'due_date': DateTime.now()
            .add(const Duration(days: 35))
            .toIso8601String(),
        'is_completed': false,
        'mileage_threshold': 45000,
        'notes': 'Book before the weekend trip.',
      },
      <String, dynamic>{
        'id': 'rem-3002',
        'vehicle_id': demoVehicleId2,
        'title': 'Cabin air filter replacement',
        'due_date': DateTime.now()
            .add(const Duration(days: 60))
            .toIso8601String(),
        'is_completed': false,
        'mileage_threshold': 20000,
        'notes': 'Use mobile service if available.',
      },
      <String, dynamic>{
        'id': 'rem-3003',
        'vehicle_id': demoVehicleId3,
        'title': 'Renew fleet permit',
        'due_date': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'is_completed': false,
        'notes': 'Bring updated mileage logs.',
      },
    ];
  }
}

class DemoService {
  DemoService._();

  static const String _dbName = 'vehicle_service_manager_demo_db';
  static const String _storeName = 'collections';

  final Map<String, List<Map<String, dynamic>>> _memoryStore =
      <String, List<Map<String, dynamic>>>{};
  Database? _database;

  static Future<DemoService> create() async {
    final DemoService service = DemoService._();
    await service._open();
    return service;
  }

  Future<void> _open() async {
    try {
      _database = await idbFactoryBrowser.open(
        _dbName,
        version: 1,
        onUpgradeNeeded: (VersionChangeEvent event) {
          final Database db = event.database;
          if (!db.objectStoreNames.contains(_storeName)) {
            db.createObjectStore(_storeName);
          }
        },
      );
    } catch (_) {
      _database = null;
    }
  }

  Future<List<Map<String, dynamic>>> loadCollection(
    String key,
    List<Map<String, dynamic>> seedData,
  ) async {
    final List<Map<String, dynamic>>? existing = await _readCollection(key);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    await saveCollection(key, seedData);
    return seedData;
  }

  Future<void> saveCollection(
    String key,
    List<Map<String, dynamic>> values,
  ) async {
    _memoryStore[key] = _cloneList(values);
    if (_database == null) {
      return;
    }

    final Transaction transaction =
        _database!.transaction(_storeName, idbModeReadWrite);
    final ObjectStore store = transaction.objectStore(_storeName);
    await store.put(_cloneList(values), key);
    await transaction.completed;
  }

  Future<List<Map<String, dynamic>>?> _readCollection(String key) async {
    if (_memoryStore.containsKey(key)) {
      return _cloneList(_memoryStore[key]!);
    }
    if (_database == null) {
      return null;
    }

    final Transaction transaction =
        _database!.transaction(_storeName, idbModeReadOnly);
    final ObjectStore store = transaction.objectStore(_storeName);
    final dynamic raw = await store.getObject(key);
    await transaction.completed;

    if (raw is List<dynamic>) {
      final List<Map<String, dynamic>> values = raw
          .whereType<Map>()
          .map((Map item) => Map<String, dynamic>.from(item))
          .toList();
      _memoryStore[key] = values;
      return _cloneList(values);
    }
    return null;
  }

  List<Map<String, dynamic>> _cloneList(List<Map<String, dynamic>> values) {
    return values
        .map((Map<String, dynamic> item) => Map<String, dynamic>.from(item))
        .toList();
  }
}
