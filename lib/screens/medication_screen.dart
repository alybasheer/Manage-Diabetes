import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../utils/theme.dart';

class MedicationScreen extends StatefulWidget {
  const MedicationScreen({super.key});

  @override
  State<MedicationScreen> createState() => _MedicationScreenState();
}

class _MedicationScreenState extends State<MedicationScreen> {
  List<Map<String, dynamic>> medications = [];

  // List of predefined times for schedule
  final List<String> times = ['07:00', '13:00', '19:00'];

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final supabase = SupabaseService();
      final medList = await supabase.getMedications();

      setState(() {
        medications = medList.map((med) {
          return {
            'name': med['name'] ?? 'Medication',
            'dosage': med['dosage'] ?? '',
            'instruction': med['instruction'] ?? '',
            'time': med['time'] ?? '',
            'taken': med['taken'] ?? false,
            'id': med['id'].toString(),
          };
        }).toList();
      });

      print('✅ Medications loaded: ${medications.length} medications');

      // Schedule reminders for all medications
      _scheduleAllReminders();
    } catch (e) {
      print('❌ Error loading medications: $e');
    }
  }

  Future<void> _scheduleAllReminders() async {
    final notificationService = NotificationService();

    for (var med in medications) {
      await notificationService.scheduleMedicationReminder(
        medicationName: med['name'],
        dosage: med['dosage'],
        time: med['time'],
      );
    }
  }

  Future<void> _saveMedications() async {
    // Supabase saves automatically through addMedication
  }

  void _addMedication() {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final instructionController = TextEditingController();
    String selectedTime = times[0];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medication'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(labelText: 'Dosage'),
              ),
              TextField(
                controller: instructionController,
                decoration: const InputDecoration(labelText: 'Instructions'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedTime,
                decoration: const InputDecoration(labelText: 'Select Time'),
                items: times
                    .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) selectedTime = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty &&
                  dosageController.text.isNotEmpty &&
                  instructionController.text.isNotEmpty) {
                try {
                  print('📝 Adding medication: ${nameController.text}');

                  final supabase = SupabaseService();
                  await supabase.addMedication(
                    name: nameController.text,
                    dosage: dosageController.text,
                    instruction: instructionController.text,
                    time: selectedTime,
                  );

                  print('✅ Medication added successfully');

                  // Schedule reminder for new medication
                  final notificationService = NotificationService();
                  await notificationService.scheduleMedicationReminder(
                    medicationName: nameController.text,
                    dosage: dosageController.text,
                    time: selectedTime,
                  );

                  // Reload medications with a small delay
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _loadMedications();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Medication added successfully!')),
                    );
                  }
                } catch (e) {
                  print('❌ Error adding medication: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMedication(int index) async {
    final medicationId = medications[index]['id'];
    final medicationName = medications[index]['name'];

    final supabase = SupabaseService();
    await supabase.deleteMedication(medicationId);

    // Cancel reminder for deleted medication
    final notificationService = NotificationService();
    await notificationService.cancelMedicationReminder(medicationName);

    await _loadMedications();
  }

  void _toggleTaken(int index, bool value) {
    setState(() {
      medications[index]['taken'] = value;
    });
    _saveMedications();
  }

  // Generate schedule counts dynamically
  Map<String, int> _generateSchedule() {
    Map<String, int> schedule = {};
    for (var time in times) {
      schedule[time] = medications.where((med) => med['time'] == time).length;
    }
    return schedule;
  }

  @override
  Widget build(BuildContext context) {
    final scheduleCounts = _generateSchedule();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addMedication,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Dynamic Schedule
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Schedule',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: times
                        .map((time) => ScheduleCard(
                              time: time,
                              count: '${scheduleCounts[time]} Meds',
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),

            // Medication List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medication List',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...medications.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> med = entry.value;
                    return MedicationItem(
                      name: med['name'],
                      dosage: med['dosage'],
                      instruction: med['instruction'],
                      taken: med['taken'],
                      onToggle: (value) => _toggleTaken(index, value),
                      onDelete: () async => await _deleteMedication(index),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String time;
  final String count;
  const ScheduleCard({required this.time, required this.count, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(
              color: AppTheme.primaryRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class MedicationItem extends StatelessWidget {
  final String name;
  final String dosage;
  final String instruction;
  final bool taken;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const MedicationItem({
    required this.name,
    required this.dosage,
    required this.instruction,
    required this.taken,
    required this.onToggle,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.medication, color: AppTheme.primaryRed),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('$dosage - $instruction',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ],
            ),
          ),
          Switch(
            value: taken,
            onChanged: onToggle,
            activeColor: AppTheme.primaryRed,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
