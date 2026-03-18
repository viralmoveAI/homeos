import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/appliance.dart';
import '../providers/appliance_providers.dart';

class AddApplianceBottomSheet extends ConsumerStatefulWidget {
  final Appliance? appliance;

  const AddApplianceBottomSheet({super.key, this.appliance});

  @override
  ConsumerState<AddApplianceBottomSheet> createState() => _AddApplianceBottomSheetState();
}

class _AddApplianceBottomSheetState extends ConsumerState<AddApplianceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _locationController;
  late TextEditingController _serialController;
  late TextEditingController _notesController;
  late TextEditingController _serviceIntervalController;
  late ApplianceCategory _category;
  DateTime? _purchaseDate;
  DateTime? _warrantyExpiry;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.appliance?.name);
    _brandController = TextEditingController(text: widget.appliance?.brand);
    _modelController = TextEditingController(text: widget.appliance?.model);
    _locationController = TextEditingController(text: widget.appliance?.location);
    _serialController = TextEditingController(text: widget.appliance?.serialNumber);
    _notesController = TextEditingController(text: widget.appliance?.notes);
    _serviceIntervalController = TextEditingController(
      text: widget.appliance?.serviceIntervalMonths.toString(),
    );
    _category = widget.appliance?.category ?? ApplianceCategory.other;
    _purchaseDate = widget.appliance?.purchaseDate;
    _warrantyExpiry = widget.appliance?.warrantyExpiry;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _locationController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    _serviceIntervalController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isPurchaseDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isPurchaseDate ? _purchaseDate : _warrantyExpiry) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (picked != null) {
      setState(() {
        if (isPurchaseDate) {
          _purchaseDate = picked;
        } else {
          _warrantyExpiry = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final appliance = Appliance(
        id: widget.appliance?.id ?? '',
        name: _nameController.text,
        category: _category,
        brand: _brandController.text,
        model: _modelController.text,
        location: _locationController.text,
        serialNumber: _serialController.text,
        notes: _notesController.text,
        serviceIntervalMonths: int.tryParse(_serviceIntervalController.text) ?? 12,
        purchaseDate: _purchaseDate ?? DateTime.now(),
        warrantyExpiry: _warrantyExpiry,
      );

      if (widget.appliance == null) {
        ref.read(applianceNotifierProvider.notifier).addAppliance(appliance);
      } else {
        ref.read(applianceNotifierProvider.notifier).updateAppliance(appliance);
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
                    widget.appliance == null ? 'Add New Appliance' : 'Edit Appliance',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildField('Name *', _nameController, 'e.g. Living Room AC', 
                  validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              const Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              DropdownButtonFormField<ApplianceCategory>(
                initialValue: _category,
                items: ApplianceCategory.values.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.displayName));
                }).toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Brand', _brandController, 'e.g. Samsung')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Model', _modelController, 'e.g. AR18TYHYCWKN')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildField('Serial Number', _serialController, 'e.g. SN123456')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildField('Location', _locationController, 'e.g. Living Room')),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Purchase Date', _purchaseDate, true)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDatePicker('Warranty Expiry', _warrantyExpiry, false)),
                ],
              ),
              const SizedBox(height: 16),
              _buildField('Service Interval (months)', _serviceIntervalController, 'e.g. 6', 
                  keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              _buildField('Notes', _notesController, 'Add some details...', maxLines: 3),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(widget.appliance == null ? 'Add Appliance' : 'Update Appliance'),
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

  Widget _buildDatePicker(String label, DateTime? date, bool isPurchaseDate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context, isPurchaseDate),
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
