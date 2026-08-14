import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
          return const Center(child: Text('Vehicle not found.'));
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
                  label: const Text('Edit'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () => _deleteVehicle(context),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              spacing: 20,
              runSpacing: 16,
              children: <Widget>[
                _DetailItem(label: 'License Plate', value: vehicle.licensePlate),
                _DetailItem(label: 'VIN', value: vehicle.vin),
                _DetailItem(
                  label: 'Mileage',
                  value: NumberFormat.decimalPattern().format(vehicle.mileage),
                ),
                _DetailItem(
                  label: 'Last Service',
                  value: vehicle.lastServiceDate == null
                      ? '—'
                      : DateFormat.yMMMd().format(vehicle.lastServiceDate!),
                ),
                _DetailItem(
                  label: 'Next Service',
                  value: vehicle.nextServiceDate == null
                      ? '—'
                      : DateFormat.yMMMd().format(vehicle.nextServiceDate!),
                ),
                _DetailItem(label: 'Notes', value: vehicle.notes ?? '—'),
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
                        'Related maintenance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.go('/maintenance/new'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Record'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (relatedRecords.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No maintenance records yet.'),
                  )
                else
                  ...relatedRecords.map((MaintenanceRecord record) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(child: Icon(Icons.build_outlined)),
                      title: Text(record.title),
                      subtitle: Text('${record.serviceType} • ${record.status}'),
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
          title: const Text('Delete vehicle?'),
          content: Text('Remove ${vehicle.displayName} from the garage?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
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

