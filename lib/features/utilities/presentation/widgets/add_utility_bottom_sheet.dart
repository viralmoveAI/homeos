import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/utility.dart';
import '../providers/utility_providers.dart';

class AddUtilityBottomSheet extends ConsumerStatefulWidget {
  final Utility? utility;

  const AddUtilityBottomSheet({super.key, this.utility});

  @override
  ConsumerState<AddUtilityBottomSheet> createState() => _AddUtilityBottomSheetState();
}

class _AddUtilityBottomSheetState extends ConsumerState<AddUtilityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _providerController;
  late TextEditingController _accountNumberController;
  late TextEditingController _costController;
  late TextEditingController _notesController;
  late String _type;
  late DateTime _billingDate;

  final List<String> _types = ['Electricity', 'Water', 'Gas', 'Internet', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.utility?.name);
    _providerController = TextEditingController(text: widget.utility?.provider);
    _accountNumberController = TextEditingController(text: widget.utility?.accountNumber);
    _costController = TextEditingController(text: widget.utility?.monthlyCost.toString());
    _notesController = TextEditingController(text: '');
    _type = widget.utility?.type ?? 'Electricity';
    _billingDate = DateTime.now(); // Model doesn't have billing date yet, using now
  }

  @override
  void dispose() {
    _nameController.dispose();
    _providerController.dispose();
    _accountNumberController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _billingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _billingDate = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cost = double.tryParse(_costController.text) ?? 0.0;
      final util = Utility(
        id: widget.utility?.id ?? '',
        name: _nameController.text,
        type: _type,
        provider: _providerController.text,
        accountNumber: _accountNumberController.text,
        monthlyCost: cost,
      );

      if (widget.utility == null) {
        ref.read(utilityNotifierProvider.notifier).addUtility(util);
      } else {
        ref.read(utilityNotifierProvider.notifier).updateUtility(util);
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
        color: Colors.white,
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
                    widget.utility == null ? 'Add Utility' : 'Edit Utility',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              _buildLabel('Utility Name *'),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'e.g., Home Electricity',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Type'),
                        DropdownButtonFormField<String>(
                          value: _type,
                          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                          onChanged: (v) => setState(() => _type = v!),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Provider'),
                        TextFormField(
                          controller: _providerController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Account Number'),
                        TextFormField(
                          controller: _accountNumberController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Monthly Cost (\$)'),
                        TextFormField(
                          controller: _costController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '0.00',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildLabel('Billing Date'),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(DateFormat('MM/dd/yyyy').format(_billingDate)),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildLabel('Notes'),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add some details...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(widget.utility == null ? 'Add Utility' : 'Update'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}
