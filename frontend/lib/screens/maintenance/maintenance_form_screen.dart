import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vehicle_service_manager_frontend/models/maintenance_record.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/maintenance_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class MaintenanceFormScreen extends StatefulWidget {
  const MaintenanceFormScreen({this.recordId, super.key});

  final String? recordId;

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _vehicleId;
  String _status = 'Completed';
  DateTime _date = DateTime.now();
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    final MaintenanceRecord? record = widget.recordId == null
        ? null
        : context.read<MaintenanceProvider>().findById(widget.recordId!);

    if (record != null) {
      _vehicleId = record.vehicleId;
      _status = record.status;
      _date = record.date;
      _titleController.text = record.title;
      _typeController.text = record.serviceType;
      _mileageController.text = record.mileage.toString();
      _costController.text = record.cost.toStringAsFixed(2);
      _notesController.text = record.notes ?? '';
    } else {
      final List<Vehicle> vehicles = context.read<VehicleProvider>().vehicles;
      if (vehicles.isNotEmpty) {
        _vehicleId = vehicles.first.id;
      }
    }

    _initialized = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Vehicle> vehicles = context.watch<VehicleProvider>().vehicles;
    final bool isEditing = widget.recordId != null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          isEditing ? 'Edit Maintenance' : 'Log Maintenance',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DropdownButtonFormField<String>(
                      value: _vehicleId,
                      items: vehicles
                          .map(
                            (Vehicle vehicle) => DropdownMenuItem<String>(
                              value: vehicle.id,
                              child: Text(vehicle.displayName),
                            ),
                          )
                          .toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _vehicleId = value;
                        });
                      },
                      validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Vehicle is required';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(labelText: 'Vehicle'),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        _textField(
                          controller: _titleController,
                          label: 'Title',
                          width: 320,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _typeController,
                          label: 'Service Type',
                          width: 220,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _mileageController,
                          label: 'Mileage',
                          width: 180,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _costController,
                          label: 'Cost',
                          width: 180,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          isRequired: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        SizedBox(
                          width: 220,
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(14),
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Date'),
                              child: Text(DateFormat.yMMMd().format(_date)),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<String>(
                            value: _status,
                            items: const <String>[
                              'Completed',
                              'Scheduled',
                              'Overdue',
                            ]
                                .map(
                                  (String value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (String? value) {
                              if (value != null) {
                                setState(() {
                                  _status = value;
                                });
                              }
                            },
                            decoration: const InputDecoration(labelText: 'Status'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Notes'),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      children: <Widget>[
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(isEditing ? 'Save Changes' : 'Create Record'),
                        ),
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required double width,
    required bool isRequired,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: (String? value) {
          if (isRequired && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _pickDate() async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        _date = selected;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final MaintenanceRecord record = MaintenanceRecord(
      id: widget.recordId ?? const Uuid().v4(),
      vehicleId: _vehicleId!,
      title: _titleController.text.trim(),
      serviceType: _typeController.text.trim(),
      date: _date,
      mileage: int.tryParse(_mileageController.text.trim()) ?? 0,
      cost: double.tryParse(_costController.text.trim()) ?? 0,
      status: _status,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    try {
      await context.read<MaintenanceProvider>().saveRecord(record);
      if (mounted) {
        context.go('/maintenance');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save maintenance record: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }

  }
}
