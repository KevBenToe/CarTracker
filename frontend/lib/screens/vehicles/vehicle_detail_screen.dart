import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/status_labels.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class VehicleDetailScreen extends StatelessWidget {
  const VehicleDetailScreen({required this.vehicleId, super.key});

  final String vehicleId;

  @override
  Widget build(BuildContext context) {
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();
    final Vehicle? cachedVehicle = vehicleProvider.findById(vehicleId);

    if (cachedVehicle != null) {
      return _VehicleDetailBody(vehicle: cachedVehicle);
    }

    return FutureBuilder<Vehicle?>(
      future: vehicleProvider.fetchVehicle(vehicleId),
      builder: (
        BuildContext context,
        AsyncSnapshot<Vehicle?> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Fahrzeug nicht gefunden.'));
        }
        return _VehicleDetailBody(vehicle: snapshot.data!);
      },
    );
  }
}

class _VehicleDetailBody extends StatelessWidget {
  const _VehicleDetailBody({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final MaintenanceProvider maintenanceProvider =
        context.watch<MaintenanceProvider>();
    final List<MaintenanceRecord> relatedRecords =
        maintenanceProvider.recordsForVehicle(vehicle.id);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    vehicle.displayName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                OutlinedButton.icon(
                  onPressed: () => context.go('/vehicles/${vehicle.id}/edit'),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Bearbeiten'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _deleteVehicle(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Löschen'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              vehicle.imageUrl!,
              height: 240,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
                  const SizedBox.shrink(),
            ),
          ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              children: <Widget>[
                _DetailItem(label: 'Kennzeichen', value: vehicle.licensePlate),
                _DetailItem(label: 'VIN', value: vehicle.vin),
                _DetailItem(
                  label: 'Kilometerstand',
                  value: NumberFormat.decimalPattern().format(vehicle.mileage),
                ),
                _DetailItem(
                  label: 'Letzter Service',
                  value: vehicle.lastServiceDate == null
                      ? '—'
                      : DateFormat.yMMMd().format(vehicle.lastServiceDate!),
                ),
                _DetailItem(
                  label: 'Nächster Service',
                  value: vehicle.nextServiceDate == null
                      ? '—'
                      : DateFormat.yMMMd().format(vehicle.nextServiceDate!),
                ),
                _DetailItem(label: 'Notizen', value: vehicle.notes ?? '—'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Zugehörige Wartungen',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.go('/maintenance/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Eintrag hinzufügen'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (relatedRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Noch keine Wartungseinträge vorhanden.'),
                  )
                else
                  ...relatedRecords.map((MaintenanceRecord record) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.build_outlined)),
                      title: Text(record.title),
                      subtitle: Text(
                        '${record.serviceType} • ${maintenanceStatusLabel(record.status)}',
                      ),
                      trailing: Text(DateFormat.yMMMd().format(record.date)),
                    );
                  }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteVehicle(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Fahrzeug löschen?'),
          content: Text('${vehicle.displayName} aus der Garage entfernen?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Löschen'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await context.read<VehicleProvider>().deleteVehicle(vehicle.id);
      if (context.mounted) {
        context.go('/vehicles');
      }
    }
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
