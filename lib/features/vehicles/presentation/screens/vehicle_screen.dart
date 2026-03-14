import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_gradient_background.dart';
import '../../domain/models/vehicle.dart';
import '../providers/vehicle_providers.dart';
import '../widgets/add_vehicle_bottom_sheet.dart';

class VehicleScreen extends ConsumerWidget {
  const VehicleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Vehicles', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showAddVehicle(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Vehicle'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
              child: Text(
                'Manage your vehicles and service schedules',
                style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 15),
              ),
            ),
            Expanded(
              child: vehiclesAsync.when(
                data: (vehicles) {
                  if (vehicles.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      return _buildVehicleCard(context, ref, vehicles[index]);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    final isServiceDue = vehicle.nextServiceDate != null && vehicle.nextServiceDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.directions_car_rounded, size: 24, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
                          ),
                          if (vehicle.make != null || vehicle.model != null)
                            Text(
                              '${vehicle.year ?? ''} ${vehicle.make ?? ''} ${vehicle.model ?? ''}'.trim(),
                              style: TextStyle(fontSize: 13, color: AppColors.textSecondary.withOpacity(0.7)),
                            ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                          onPressed: () => _showEditVehicle(context, vehicle),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                          onPressed: () => _deleteVehicle(context, ref, vehicle),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (vehicle.licensePlate != null)
                  _buildDetailRow(Icons.pin_rounded, 'Plate: ${vehicle.licensePlate}'),
                if (vehicle.lastServiceDate != null)
                  _buildDetailRow(Icons.build_circle_outlined, 'Last service: ${DateFormat('MM/dd/yyyy').format(vehicle.lastServiceDate!)}'),
                if (vehicle.nextServiceDate != null)
                  _buildDetailRow(
                    Icons.event_note_rounded,
                    'Next service: ${DateFormat('MM/dd/yyyy').format(vehicle.nextServiceDate!)} ${isServiceDue ? '(Due)' : ''}',
                    textColor: isServiceDue ? Colors.redAccent : null,
                  ),
                if (isServiceDue) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Service Due',
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textHint),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13, color: textColor ?? AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 80, color: AppColors.textHint.withOpacity(0.3)),
          const SizedBox(height: 20),
          const Text('No vehicles added yet', style: TextStyle(color: AppColors.textHint, fontSize: 18)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => _showAddVehicle(context), child: const Text('Add your first vehicle')),
        ],
      ),
    );
  }

  void _showAddVehicle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddVehicleBottomSheet(),
    );
  }

  void _showEditVehicle(BuildContext context, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddVehicleBottomSheet(vehicle: vehicle),
    );
  }

  void _deleteVehicle(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete ${vehicle.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(vehicleNotifierProvider.notifier).deleteVehicle(vehicle.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
