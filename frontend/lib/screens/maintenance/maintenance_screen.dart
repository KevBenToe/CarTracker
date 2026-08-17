import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/status_labels.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MaintenanceProvider provider = context.watch<MaintenanceProvider>();
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();

    return RefreshIndicator(
      onRefresh: provider.loadRecords,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Wartung',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.go('/maintenance/new'),
                icon: const Icon(Icons.add),
                label: const Text('Eintrag hinzufügen'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (provider.isLoading && provider.records.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (provider.records.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Noch keine Wartungseinträge vorhanden.'),
              ),
            )
          else
            ...provider.records.map((MaintenanceRecord record) {
              final String vehicleName =
                  vehicleProvider.findById(record.vehicleId)?.displayName ??
                      'Unbekanntes Fahrzeug';
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      child: Icon(
                        record.status == 'Completed'
                            ? Icons.check_circle_outline
                            : Icons.schedule_outlined,
                      ),
                    ),
                    title: Text(record.title),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '$vehicleName • ${record.serviceType} • ${NumberFormat.simpleCurrency().format(record.cost)}',
                      ),
                    ),
                    trailing: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      children: <Widget>[
                        Chip(label: Text(maintenanceStatusLabel(record.status))),
                        Text(DateFormat.yMMMd().format(record.date)),
                        IconButton(
                          tooltip: 'Eintrag bearbeiten',
                          onPressed: () => context.go('/maintenance/${record.id}/edit'),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
