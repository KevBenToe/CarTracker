import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/constants.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  _VehicleSortOption _sortOption = _VehicleSortOption.none;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vehicle> _filtered(List<Vehicle> vehicles) {
    List<Vehicle> result = vehicles;
    if (_searchQuery.isNotEmpty) {
      final String q = _searchQuery.toLowerCase();
      result = result.where((Vehicle v) {
        return v.licensePlate.toLowerCase().contains(q) ||
            v.vin.toLowerCase().contains(q) ||
            v.make.toLowerCase().contains(q) ||
            v.model.toLowerCase().contains(q) ||
            (v.nickname?.toLowerCase().contains(q) ?? false);
      }).toList();
    }
    switch (_sortOption) {
      case _VehicleSortOption.licensePlate:
        result = List<Vehicle>.from(result)
          ..sort((Vehicle a, Vehicle b) => a.licensePlate.compareTo(b.licensePlate));
      case _VehicleSortOption.nextServiceDate:
        result = List<Vehicle>.from(result)
          ..sort((Vehicle a, Vehicle b) {
            if (a.nextServiceDate == null && b.nextServiceDate == null) return 0;
            if (a.nextServiceDate == null) return 1;
            if (b.nextServiceDate == null) return -1;
            return a.nextServiceDate!.compareTo(b.nextServiceDate!);
          });
      case _VehicleSortOption.none:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final VehicleProvider provider = context.watch<VehicleProvider>();

    if (provider.isLoading && provider.vehicles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.vehicles.isEmpty) {
      return Center(child: Text(provider.errorMessage!));
    }

    final List<Vehicle> displayed = _filtered(provider.vehicles);

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
                      'Fahrzeuge',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/vehicles/new'),
                    icon: const Icon(Icons.add),
                    label: const Text('Fahrzeug hinzufügen'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Suchen (Kennzeichen, VIN, Marke …)',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                tooltip: 'Suche zurücksetzen',
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: const OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (String value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<_VehicleSortOption>(
                    tooltip: 'Sortieren',
                    icon: const Icon(Icons.sort),
                    initialValue: _sortOption,
                    onSelected: (_VehicleSortOption option) =>
                        setState(() => _sortOption = option),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<_VehicleSortOption>>[
                      const PopupMenuItem<_VehicleSortOption>(
                        value: _VehicleSortOption.none,
                        child: Text('Standard'),
                      ),
                      const PopupMenuItem<_VehicleSortOption>(
                        value: _VehicleSortOption.licensePlate,
                        child: Text('Kennzeichen'),
                      ),
                      const PopupMenuItem<_VehicleSortOption>(
                        value: _VehicleSortOption.nextServiceDate,
                        child: Text('Nächster Service'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (displayed.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Keine Fahrzeuge gefunden.'),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: displayed.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.38,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final Vehicle vehicle = displayed[index];
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

enum _VehicleSortOption { none, licensePlate, nextServiceDate }

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
              _VehicleLine(label: 'Kennzeichen', value: vehicle.licensePlate),
              _VehicleLine(label: 'VIN', value: vehicle.vin),
              _VehicleLine(
                label: 'Kilometerstand',
                value: NumberFormat.decimalPattern().format(vehicle.mileage),
              ),
              if (vehicle.nextServiceDate != null)
                _VehicleLine(
                  label: 'Nächster Service',
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
