import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/models/reminder.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';
import 'package:vehicle_service_manager_frontend/repositories/reminder_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();
    final MaintenanceProvider maintenanceProvider =
        context.watch<MaintenanceProvider>();
    final ReminderRepository reminderRepository =
        context.watch<ReminderRepository>();

    final NumberFormat currency = NumberFormat.simpleCurrency();
    final List<Widget> content = <Widget>[
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: <Widget>[
          _MetricCard(
            title: 'Vehicles',
            value: '${vehicleProvider.vehicles.length}',
            icon: Icons.directions_car_filled_outlined,
          ),
          _MetricCard(
            title: 'Maintenance Records',
            value: '${maintenanceProvider.records.length}',
            icon: Icons.build_circle_outlined,
          ),
          _MetricCard(
            title: 'Scheduled Services',
            value:
                '${maintenanceProvider.records.where((record) => record.status != 'Completed').length}',
            icon: Icons.event_available_outlined,
          ),
          _MetricCard(
            title: 'Service Spend',
            value: currency.format(
              maintenanceProvider.records.fold<double>(
                0,
                (double total, record) => total + record.cost,
              ),
            ),
            icon: Icons.payments_outlined,
          ),
        ],
      ),
      const SizedBox(height: 24),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: <Widget>[
          FilledButton.icon(
            onPressed: () => context.go('/vehicles/new'),
            icon: const Icon(Icons.add),
            label: const Text('Add vehicle'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => context.go('/maintenance/new'),
            icon: const Icon(Icons.playlist_add_check_circle_outlined),
            label: const Text('Log maintenance'),
          ),
          OutlinedButton.icon(
            onPressed: () => context.go('/documents'),
            icon: const Icon(Icons.folder_copy_outlined),
            label: const Text('View documents'),
          ),
        ],
      ),
      const SizedBox(height: 24),
      _SectionCard(
        title: 'Recent maintenance',
        child: maintenanceProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: maintenanceProvider.records.take(4).map((record) {
                  final String vehicleName =
                      vehicleProvider.findById(record.vehicleId)?.displayName ??
                          'Unknown vehicle';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      child: Icon(Icons.build_outlined),
                    ),
                    title: Text(record.title),
                    subtitle: Text('$vehicleName • ${record.serviceType}'),
                    trailing: Text(DateFormat.yMMMd().format(record.date)),
                  );
                }).toList(),
              ),
      ),
      const SizedBox(height: 16),
      FutureBuilder<List<Reminder>>(
        future: reminderRepository.getReminders(),
        builder: (
          BuildContext context,
          AsyncSnapshot<List<Reminder>> snapshot,
        ) {
          final List<Reminder> reminders = snapshot.data ?? <Reminder>[];
          return _SectionCard(
            title: 'Upcoming reminders',
            child: snapshot.connectionState == ConnectionState.waiting
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: reminders.take(4).map((Reminder reminder) {
                      final String vehicleName =
                          vehicleProvider.findById(reminder.vehicleId)?.displayName ??
                              'Unknown vehicle';
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          reminder.isCompleted
                              ? Icons.check_circle_outline
                              : Icons.notification_important_outlined,
                        ),
                        title: Text(reminder.title),
                        subtitle: Text(vehicleName),
                        trailing: Text(
                          DateFormat.yMMMd().format(reminder.dueDate),
                        ),
                      );
                    }).toList(),
                  ),
          );
        },
      ),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait<void>(<Future<void>>[
          vehicleProvider.loadVehicles(),
          maintenanceProvider.loadRecords(),
        ]);
      },
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: content,
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              CircleAvatar(radius: 24, child: Icon(icon)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(value, style: Theme.of(context).textTheme.headlineSmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

