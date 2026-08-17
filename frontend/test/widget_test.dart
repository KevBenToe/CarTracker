import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vehicle_service_manager_frontend/app.dart';
import 'package:vehicle_service_manager_frontend/models/document.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/models/reminder.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/app_state_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/theme_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';
import 'package:vehicle_service_manager_frontend/repositories/document_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/maintenance_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/reminder_repository.dart';
import 'package:vehicle_service_manager_frontend/repositories/vehicle_repository.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';

void main() {
  testWidgets('app renders dashboard shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final AppStateProvider appState = AppStateProvider(
      apiService: _FakeApiService(),
      sharedPreferences: prefs,
    );
    await appState.initialize();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: appState),
          ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(sharedPreferences: prefs),
          ),
          Provider<DocumentRepository>(
            create: (_) => _FakeDocumentRepository(),
          ),
          Provider<ReminderRepository>(
            create: (_) => _FakeReminderRepository(),
          ),
          ChangeNotifierProvider<VehicleProvider>(
            create: (_) => VehicleProvider(repository: _FakeVehicleRepository()),
          ),
          ChangeNotifierProvider<MaintenanceProvider>(
            create: (_) =>
                MaintenanceProvider(repository: _FakeMaintenanceRepository()),
          ),
        ],
        child: VehicleServiceManagerApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Übersicht'), findsNWidgets(2));
    expect(find.text('Fahrzeug hinzufügen'), findsOneWidget);

    final Finder appBarGradientFinder = find.descendant(
      of: find.byType(AppBar),
      matching: find.byWidgetPredicate(
        (Widget widget) =>
            widget is DecoratedBox &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).gradient is LinearGradient,
      ),
    );
    final DecoratedBox flexibleSpace =
        tester.widget<DecoratedBox>(appBarGradientFinder.first);
    final BoxDecoration decoration = flexibleSpace.decoration as BoxDecoration;
    final LinearGradient gradient = decoration.gradient! as LinearGradient;
    expect(gradient.colors, <Color>[Colors.black, Colors.red]);
  });
}

class _FakeApiService extends ApiService {
  _FakeApiService() : super(baseUrl: 'http://localhost:8000/api/v1');

  @override
  Future<bool> checkConnectivity() async => false;
}

class _FakeVehicleRepository implements VehicleRepository {
  final List<Vehicle> _vehicles = <Vehicle>[
    Vehicle(
      id: '1',
      make: 'Honda',
      model: 'Civic',
      year: 2022,
      licensePlate: 'TEST-1',
      vin: 'VIN123',
      mileage: 10000,
    ),
  ];

  @override
  Future<Vehicle> createVehicle(Vehicle vehicle) async {
    _vehicles.add(vehicle);
    return vehicle;
  }

  @override
  Future<void> deleteVehicle(String id) async {
    _vehicles.removeWhere((Vehicle vehicle) => vehicle.id == id);
  }

  @override
  Future<Vehicle> getVehicle(String id) async {
    return _vehicles.firstWhere((Vehicle vehicle) => vehicle.id == id);
  }

  @override
  Future<List<Vehicle>> getVehicles() async => List<Vehicle>.from(_vehicles);

  @override
  Future<Vehicle> updateVehicle(Vehicle vehicle) async => vehicle;
}

class _FakeMaintenanceRepository implements MaintenanceRepository {
  @override
  Future<MaintenanceRecord> createRecord(MaintenanceRecord record) async => record;

  @override
  Future<void> deleteRecord(String id) async {}

  @override
  Future<MaintenanceRecord> getRecord(String id) async {
    return MaintenanceRecord(
      id: id,
      vehicleId: '1',
      title: 'Oil Change',
      serviceType: 'Routine',
      date: DateTime.now(),
      mileage: 10000,
      cost: 50,
      status: 'Completed',
    );
  }

  @override
  Future<List<MaintenanceRecord>> getRecords() async {
    return <MaintenanceRecord>[
      MaintenanceRecord(
        id: 'm1',
        vehicleId: '1',
        title: 'Oil Change',
        serviceType: 'Routine',
        date: DateTime.now(),
        mileage: 10000,
        cost: 50,
        status: 'Completed',
      ),
    ];
  }

  @override
  Future<List<MaintenanceRecord>> getRecordsForVehicle(String vehicleId) async {
    return getRecords();
  }

  @override
  Future<MaintenanceRecord> updateRecord(MaintenanceRecord record) async => record;
}

class _FakeDocumentRepository implements DocumentRepository {
  @override
  Future<VehicleDocument> createDocument(VehicleDocument document) async => document;

  @override
  Future<void> deleteDocument(String id) async {}

  @override
  Future<VehicleDocument> getDocument(String id) async {
    return VehicleDocument(
      id: id,
      vehicleId: '1',
      name: 'Insurance',
      type: 'Insurance',
      issuedDate: DateTime.now(),
    );
  }

  @override
  Future<List<VehicleDocument>> getDocuments() async {
    return <VehicleDocument>[
      VehicleDocument(
        id: 'd1',
        vehicleId: '1',
        name: 'Insurance',
        type: 'Insurance',
        issuedDate: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<VehicleDocument>> getDocumentsForVehicle(String vehicleId) async {
    return getDocuments();
  }

  @override
  Future<VehicleDocument> updateDocument(VehicleDocument document) async => document;
}

class _FakeReminderRepository implements ReminderRepository {
  @override
  Future<Reminder> createReminder(Reminder reminder) async => reminder;

  @override
  Future<void> deleteReminder(String id) async {}

  @override
  Future<Reminder> getReminder(String id) async {
    return Reminder(
      id: id,
      vehicleId: '1',
      title: 'Renew insurance',
      dueDate: DateTime.now(),
      isCompleted: false,
    );
  }

  @override
  Future<List<Reminder>> getReminders() async {
    return <Reminder>[
      Reminder(
        id: 'r1',
        vehicleId: '1',
        title: 'Renew insurance',
        dueDate: DateTime.now(),
        isCompleted: false,
      ),
    ];
  }

  @override
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId) async {
    return getReminders();
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async => reminder;
}
