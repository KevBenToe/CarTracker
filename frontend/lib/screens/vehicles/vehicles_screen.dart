import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/constants.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VehicleProvider provider = context.watch<VehicleProvider>();

    if (provider.isLoading && provider.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.vehicles.isEmpty) {
      return Center(child: Text(provider.errorMessage!));
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = constraints.maxWidth >= kDesktopBreakpoint
            ? 3
            : constraints.maxWidth >= kTabletBreakpoint
                ? 2
                : 1;
        return RefreshIndicator(
          onRefresh: provider.loadVehicles,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      'Vehicles',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/vehicles/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vehicle'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.vehicles.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.38,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final Vehicle vehicle = provider.vehicles[index];
                  return _VehicleCard(vehicle: vehicle);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/vehicles/${vehicle.id}'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const CircleAvatar(
                    radius: 24,
                    child: Icon(Icons.directions_car_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vehicle.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _VehicleLine(label: 'Plate', value: vehicle.licensePlate),
              _VehicleLine(label: 'VIN', value: vehicle.vin),
              _VehicleLine(
                label: 'Mileage',
                value: NumberFormat.decimalPattern().format(vehicle.mileage),
              ),
              if (vehicle.nextServiceDate != null)
                _VehicleLine(
                  label: 'Next service',
                  value: DateFormat.yMMMd().format(vehicle.nextServiceDate!),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleLine extends StatelessWidget {
  const _VehicleLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodyMedium,
          children: <InlineSpan>[
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

