import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/models/reminder.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';
import 'package:vehicle_service_manager_frontend/repositories/reminder_repository.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    final ReminderRepository repository = context.watch<ReminderRepository>();
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();

    return FutureBuilder<List<Reminder>>(
      future: repository.getReminders(),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<Reminder>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting && !_updating) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final List<Reminder> reminders = snapshot.data ?? <Reminder>[];
        return ListView(
          padding: const EdgeInsets.all(20),
          children: <Widget>[
            Text(
              'Reminders',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            if (reminders.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No reminders scheduled.'),
                ),
              )
            else
              ...reminders.map((Reminder reminder) {
                final String vehicleName =
                    vehicleProvider.findById(reminder.vehicleId)?.displayName ??
                        'Unknown vehicle';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: CheckboxListTile(
                      contentPadding: const EdgeInsets.all(16),
                      value: reminder.isCompleted,
                      onChanged: (bool? value) {
                        _toggleReminder(repository, reminder, value ?? false);
                      },
                      title: Text(reminder.title),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '$vehicleName\nDue ${DateFormat.yMMMd().format(reminder.dueDate)}${reminder.mileageThreshold != null ? ' • ${NumberFormat.decimalPattern().format(reminder.mileageThreshold)} mi' : ''}',
                        ),
                      ),
                      secondary: const Icon(Icons.notifications_active_outlined),
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  Future<void> _toggleReminder(
    ReminderRepository repository,
    Reminder reminder,
    bool isCompleted,
  ) async {
    setState(() {
      _updating = true;
    });
    await repository.updateReminder(reminder.copyWith(isCompleted: isCompleted));
    if (mounted) {
      setState(() {
        _updating = false;
      });
    }
  }
}

