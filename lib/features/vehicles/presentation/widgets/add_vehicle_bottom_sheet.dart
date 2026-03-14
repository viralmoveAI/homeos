import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/vehicle.dart';
import '../providers/vehicle_providers.dart';

class AddVehicleBottomSheet extends ConsumerStatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleBottomSheet({super.key, this.vehicle});

  @override
  ConsumerState<AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends ConsumerState<AddVehicleBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _makeController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _plateController;
  late TextEditingController _vinController;
  late TextEditingController _notesController;
  DateTime? _lastService;
  DateTime? _nextService;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.vehicle?.name);
    _makeController = TextEditingController(text: widget.vehicle?.make);
    _modelController = TextEditingController(text: widget.vehicle?.model);
    _yearController = TextEditingController(text: widget.vehicle?.year?.toString());
    _plateController = TextEditingController(text: widget.vehicle?.licensePlate);
    _vinController = TextEditingController(text: widget.vehicle?.vin);
    _notesController = TextEditingController(text: widget.vehicle?.notes);
    _lastService = widget.vehicle?.lastServiceDate;
    _nextService = widget.vehicle?.nextServiceDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    _vinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isLastService) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isLastService ? _lastService : _nextService) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) {
      setState(() {
        if (isLastService) {
          _lastService = picked;
        } else {
          _nextService = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final vehicle = Vehicle(
        id: widget.vehicle?.id ?? '',
        name: _nameController.text,
        make: _makeController.text.isEmpty ? null : _makeController.text,
        model: _modelController.text.isEmpty ? null : _modelController.text,
        year: int.tryParse(_yearController.text),
        licensePlate: _plateController.text.isEmpty ? null : _plateController.text,
        vin: _vinController.text.isEmpty ? null : _vinController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        lastServiceDate: _lastService,
        nextServiceDate: _nextService,
      );

      if (widget.vehicle == null) {
        ref.read(vehicleNotifierProvider.notifier).addVehicle(vehicle);
      } else {
        ref.read(vehicleNotifierProvider.notifier).updateVehicle(vehicle);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 32,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    widget.vehicle == null ? 'Add New Vehicle' : 'Edit Vehicle',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('Vehicle Name *', _nameController, 'e.g., Family SUV', 
                  validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Make', _makeController, 'e.g., Toyota')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Model', _modelController, 'e.g., RAV4')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Year', _yearController, 'e.g., 2023', keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('License Plate', _plateController, 'e.g., ABC-1234')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('VIN', _vinController, 'Vehicle Identification Number')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDatePicker('Last Service', _lastService, true)),
                ],
              ),
              const SizedBox(height: 16),
              _buildDatePicker('Next Service', _nextService, false),
              const SizedBox(height: 16),
              _buildField('Notes', _notesController, 'Add some details...', maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.vehicle == null ? 'Add Vehicle' : 'Update Vehicle'),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, 
      {String? Function(String?)? validator, TextInputType? keyboardType, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, bool isLastService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isLastService),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceWhite,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(date == null ? 'mm/dd/yyyy' : DateFormat('MM/dd/yyyy').format(date),
                    style: TextStyle(fontSize: 13, color: date == null ? AppColors.textHint : AppColors.textPrimary)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
