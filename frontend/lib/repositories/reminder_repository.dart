import 'package:vehicle_service_manager_frontend/models/reminder.dart';
import 'package:vehicle_service_manager_frontend/services/api_service.dart';
import 'package:vehicle_service_manager_frontend/services/demo_service.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getReminders();
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId);
  Future<Reminder> getReminder(String id);
  Future<Reminder> createReminder(Reminder reminder);
  Future<Reminder> updateReminder(Reminder reminder);
  Future<void> deleteReminder(String id);
}

class ApiReminderRepository implements ReminderRepository {
  ApiReminderRepository({required ApiService apiService}) : _apiService = apiService;

  final ApiService _apiService;

  @override
  Future<List<Reminder>> getReminders() async {
    final List<dynamic> data = await _apiService.getList('reminders/');
    return data
        .whereType<Map>()
        .map((Map item) => Reminder.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  @override
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId) async {
    final List<Reminder> all = await getReminders();
    return all.where((Reminder reminder) => reminder.vehicleId == vehicleId).toList();
  }

  @override
  Future<Reminder> getReminder(String id) async {
    final Map<String, dynamic> data = await _apiService.getObject('reminders/$id/');
    return Reminder.fromJson(data);
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    final Map<String, dynamic> data =
        await _apiService.postObject('reminders/', reminder.toJson());
    return Reminder.fromJson(data);
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    final Map<String, dynamic> data =
        await _apiService.putObject('reminders/${reminder.id}/', reminder.toJson());
    return Reminder.fromJson(data);
  }

  @override
  Future<void> deleteReminder(String id) {
    return _apiService.delete('reminders/$id/');
  }
}

class DemoReminderRepository implements ReminderRepository {
  DemoReminderRepository({required DemoService demoService}) : _demoService = demoService;

  final DemoService _demoService;
  final List<Reminder> _reminders = <Reminder>[];
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) {
      return;
    }
    final List<Map<String, dynamic>> data = await _demoService.loadCollection(
      'reminders',
      DemoSeeds.reminders(),
    );
    _reminders
      ..clear()
      ..addAll(data.map(Reminder.fromJson));
    _initialized = true;
  }

  Future<void> _persist() async {
    await _demoService.saveCollection(
      'reminders',
      _reminders.map((Reminder reminder) => reminder.toJson()).toList(),
    );
  }

  @override
  Future<List<Reminder>> getReminders() async {
    await _ensureInitialized();
    final List<Reminder> values = List<Reminder>.from(_reminders);
    values.sort((Reminder a, Reminder b) => a.dueDate.compareTo(b.dueDate));
    return values;
  }

  @override
  Future<List<Reminder>> getRemindersForVehicle(String vehicleId) async {
    final List<Reminder> all = await getReminders();
    return all.where((Reminder reminder) => reminder.vehicleId == vehicleId).toList();
  }

  @override
  Future<Reminder> getReminder(String id) async {
    await _ensureInitialized();
    return _reminders.firstWhere((Reminder reminder) => reminder.id == id);
  }

  @override
  Future<Reminder> createReminder(Reminder reminder) async {
    await _ensureInitialized();
    _reminders.add(reminder);
    await _persist();
    return reminder;
  }

  @override
  Future<Reminder> updateReminder(Reminder reminder) async {
    await _ensureInitialized();
    final int index =
        _reminders.indexWhere((Reminder item) => item.id == reminder.id);
    if (index == -1) {
      throw StateError('Reminder ${reminder.id} not found.');
    }
    _reminders[index] = reminder;
    await _persist();
    return reminder;
  }

  @override
  Future<void> deleteReminder(String id) async {
    await _ensureInitialized();
    _reminders.removeWhere((Reminder reminder) => reminder.id == id);
    await _persist();
  }
}

