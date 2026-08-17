import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:vehicle_service_manager_frontend/models/vehicle.dart';
import 'package:vehicle_service_manager_frontend/providers/vehicle_provider.dart';

class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({this.vehicleId, super.key});

  final String? vehicleId;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _lastServiceDate;
  DateTime? _nextServiceDate;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }
    final Vehicle? vehicle = widget.vehicleId == null
        ? null
        : context.read<VehicleProvider>().findById(widget.vehicleId!);
    if (vehicle != null) {
      _nicknameController.text = vehicle.nickname ?? '';
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _plateController.text = vehicle.licensePlate;
      _vinController.text = vehicle.vin;
      _mileageController.text = vehicle.mileage.toString();
      _notesController.text = vehicle.notes ?? '';
      _lastServiceDate = vehicle.lastServiceDate;
      _nextServiceDate = vehicle.nextServiceDate;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.vehicleId != null;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          isEditing ? 'Fahrzeug bearbeiten' : 'Fahrzeug hinzufügen',
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
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        _textField(
                          controller: _nicknameController,
                          label: 'Spitzname',
                          width: 320,
                        ),
                        _textField(
                          controller: _makeController,
                          label: 'Marke',
                          width: 220,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _modelController,
                          label: 'Modell',
                          width: 220,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _yearController,
                          label: 'Baujahr',
                          width: 160,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _plateController,
                          label: 'Kennzeichen',
                          width: 220,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _vinController,
                          label: 'VIN',
                          width: 320,
                          isRequired: true,
                        ),
                        _textField(
                          controller: _mileageController,
                          label: 'Kilometerstand',
                          width: 200,
                          keyboardType: TextInputType.number,
                          isRequired: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: <Widget>[
                        _DatePickerField(
                          label: 'Letzter Service',
                          value: _lastServiceDate,
                          onTap: () => _selectDate(isLastService: true),
                        ),
                        _DatePickerField(
                          label: 'Nächster Service',
                          value: _nextServiceDate,
                          onTap: () => _selectDate(isLastService: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Notizen'),
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
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
                          label: Text(
                            isEditing
                                ? 'Änderungen speichern'
                                : 'Fahrzeug erstellen',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => context.pop(),
                          child: const Text('Abbrechen'),
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
    bool isRequired = false,
    TextInputType? keyboardType,
  }) {
    return SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: isRequired
            ? (String? value) {
                if (value == null || value.trim().isEmpty) {
                  return '$label ist erforderlich';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Future<void> _selectDate({required bool isLastService}) async {
    final DateTime initialDate = isLastService
        ? (_lastServiceDate ?? DateTime.now())
        : (_nextServiceDate ?? DateTime.now().add(const Duration(days: 30)));

    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected != null) {
      setState(() {
        if (isLastService) {
          _lastServiceDate = selected;
        } else {
          _nextServiceDate = selected;
        }
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

    final VehicleProvider provider = context.read<VehicleProvider>();
    final Vehicle vehicle = Vehicle(
      id: widget.vehicleId ?? const Uuid().v4(),
      nickname:
          _nicknameController.text.trim().isEmpty ? null : _nicknameController.text.trim(),
      make: _makeController.text.trim(),
      model: _modelController.text.trim(),
      year: int.tryParse(_yearController.text.trim()) ?? DateTime.now().year,
      licensePlate: _plateController.text.trim(),
      vin: _vinController.text.trim(),
      mileage: int.tryParse(_mileageController.text.trim()) ?? 0,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      lastServiceDate: _lastServiceDate,
      nextServiceDate: _nextServiceDate,
    );

    try {
      await provider.saveVehicle(vehicle);
      if (mounted) {
        context.go('/vehicles/${vehicle.id}');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fahrzeug konnte nicht gespeichert werden: $error'),
          ),
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

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Text(
            value == null ? 'Datum auswählen' : DateFormat.yMMMd().format(value!),
          ),
        ),
      ),
    );
  }
}
