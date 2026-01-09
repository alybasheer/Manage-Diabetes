import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/supabase_service.dart';
import '../utils/theme.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    try {
      final supabase = SupabaseService();
      final mealsList = await supabase.getMeals();

      setState(() {
        meals = mealsList.map((meal) {
          return {
            'title': meal['title'] ?? 'Meal',
            'time': meal['time'] ?? '',
            'description': meal['description'] ?? '',
            'calories': meal['calories'] ?? '0',
            'id': meal['id'].toString(),
          };
        }).toList();
      });

      print('✅ Meals loaded: ${meals.length} meals');
    } catch (e) {
      print('❌ Error loading meals: $e');
    }
  }

  Future<void> _saveMeals() async {
    // Supabase saves automatically through addMeal
  }

  void _addMeal() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();
    final descriptionController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Meal'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Meal Name'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time (HH:mm)'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calories'),
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
              if (titleController.text.isNotEmpty &&
                  timeController.text.isNotEmpty &&
                  descriptionController.text.isNotEmpty &&
                  caloriesController.text.isNotEmpty) {
                try {
                  print('📝 Adding meal: ${titleController.text}');

                  final supabase = SupabaseService();
                  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

                  await supabase.addMeal(
                    title: titleController.text,
                    time: timeController.text,
                    description: descriptionController.text,
                    calories: caloriesController.text,
                    date: date,
                  );

                  print('✅ Meal added successfully');

                  // Reload meals with a small delay
                  await Future.delayed(const Duration(milliseconds: 500));
                  await _loadMeals();

                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Meal added successfully!')),
                    );
                  }
                } catch (e) {
                  print('❌ Error adding meal: $e');
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

  void _deleteMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
    _saveMeals();
  }

  void _showCalendar() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Selected date: ${DateFormat('yyyy-MM-dd').format(picked)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diet Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showCalendar,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Calorie Summary (static example)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryRed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Total Calories Today',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '1,250',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' / 1,800',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        ' kcal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      NutrientInfo(
                          label: 'Carbs', amount: '150g', percentage: '60%'),
                      NutrientInfo(
                          label: 'Protein', amount: '75g', percentage: '25%'),
                      NutrientInfo(
                          label: 'Fat', amount: '40g', percentage: '15%'),
                    ],
                  ),
                ],
              ),
            ),

            // Meal List
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meal Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...meals.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> meal = entry.value;
                    return MealCard(
                      title: meal['title']!,
                      time: meal['time']!,
                      description: meal['description']!,
                      calories: meal['calories']!,
                      onDelete: () => _deleteMeal(index),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryRed,
        onPressed: _addMeal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NutrientInfo extends StatelessWidget {
  final String label;
  final String amount;
  final String percentage;
  const NutrientInfo(
      {required this.label,
      required this.amount,
      required this.percentage,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(amount,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
        Text(percentage,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}

class MealCard extends StatelessWidget {
  final String title;
  final String time;
  final String description;
  final String calories;
  final VoidCallback onDelete;
  const MealCard({
    required this.title,
    required this.time,
    required this.description,
    required this.calories,
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
            child: const Icon(Icons.restaurant,
                color: AppTheme.primaryRed, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(time,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 4),
                Text(calories,
                    style: TextStyle(
                        color: AppTheme.primaryRed,
                        fontWeight: FontWeight.bold)),
              ],
            ),
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
