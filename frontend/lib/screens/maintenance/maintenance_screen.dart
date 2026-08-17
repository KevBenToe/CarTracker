import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/status_labels.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // null = all
  _MaintenanceSortOption _sortOption = _MaintenanceSortOption.none;

  static const List<(String, String)> _statusOptions = <(String, String)>[
    ('scheduled', 'Geplant'),
    ('completed', 'Abgeschlossen'),
    ('cancelled', 'Abgebrochen'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MaintenanceRecord> _filtered(List<MaintenanceRecord> records) {
    List<MaintenanceRecord> result = records;
    if (_searchQuery.isNotEmpty) {
      final String q = _searchQuery.toLowerCase();
      result = result
          .where((MaintenanceRecord r) => r.title.toLowerCase().contains(q))
          .toList();
    }
    if (_statusFilter != null) {
      result = result
          .where((MaintenanceRecord r) =>
              r.status.toLowerCase() == _statusFilter)
          .toList();
    }
    switch (_sortOption) {
      case _MaintenanceSortOption.dateAsc:
        result = List<MaintenanceRecord>.from(result)
          ..sort((MaintenanceRecord a, MaintenanceRecord b) =>
              a.date.compareTo(b.date));
      case _MaintenanceSortOption.dateDesc:
        result = List<MaintenanceRecord>.from(result)
          ..sort((MaintenanceRecord a, MaintenanceRecord b) =>
              b.date.compareTo(a.date));
      case _MaintenanceSortOption.none:
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final MaintenanceProvider provider = context.watch<MaintenanceProvider>();
    final VehicleProvider vehicleProvider = context.watch<VehicleProvider>();
    final List<MaintenanceRecord> displayed = _filtered(provider.records);

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
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Suchen (Titel …)',
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
              PopupMenuButton<_MaintenanceSortOption>(
                tooltip: 'Sortieren',
                icon: const Icon(Icons.sort),
                initialValue: _sortOption,
                onSelected: (_MaintenanceSortOption option) =>
                    setState(() => _sortOption = option),
                itemBuilder: (BuildContext context) =>
                    <PopupMenuEntry<_MaintenanceSortOption>>[
                  const PopupMenuItem<_MaintenanceSortOption>(
                    value: _MaintenanceSortOption.none,
                    child: Text('Standard'),
                  ),
                  const PopupMenuItem<_MaintenanceSortOption>(
                    value: _MaintenanceSortOption.dateAsc,
                    child: Text('Datum aufsteigend'),
                  ),
                  const PopupMenuItem<_MaintenanceSortOption>(
                    value: _MaintenanceSortOption.dateDesc,
                    child: Text('Datum absteigend'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                FilterChip(
                  label: const Text('Alle'),
                  selected: _statusFilter == null,
                  onSelected: (_) => setState(() => _statusFilter = null),
                ),
                ..._statusOptions.map(((String, String) opt) {
                  final String value = opt.$1;
                  final String label = opt.$2;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(label),
                      selected: _statusFilter == value,
                      onSelected: (bool selected) => setState(
                        () => _statusFilter = selected ? value : null,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (provider.isLoading && provider.records.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (displayed.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Keine Wartungseinträge gefunden.'),
              ),
            )
          else
            ...displayed.map((MaintenanceRecord record) {
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
                          onPressed: () =>
                              context.go('/maintenance/${record.id}/edit'),
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

enum _MaintenanceSortOption { none, dateAsc, dateDesc }
