import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../models/meal_model.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  int? _editingIndex;
  String? _editingDocId;

  @override
  void initState() {
    super.initState();
    Provider.of<MealProvider>(context, listen: false)
        .fetchMealsFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = Provider.of<MealProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MEAL TRACKER 🍽️'),
        backgroundColor: const Color(0xFF6FA89A),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Center(
              child: Text(
                'Meals today 🥗',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6FA89A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: mealProvider.meals.isEmpty
                  ? const Text(
                'No meals added',
                style: TextStyle(color: Colors.white),
              )
                  : Column(
                children:
                List.generate(mealProvider.meals.length, (index) {
                  final meal = mealProvider.meals[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${meal.name} - ${meal.calories} kcal',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                _editingIndex = index;
                                _editingDocId = meal.id;
                                _nameController.text = meal.name;
                                _calorieController.text =
                                    meal.calories.toString();
                                _selectedDate = meal.date;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.white),
                            onPressed: () {
                              mealProvider.deleteMeal(meal.id, index);
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              '+ Add Meal Form',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            const Text('1. Meal Name'),
            const SizedBox(height: 6),
            _inputField(_nameController, 'Enter meal name'),

            const SizedBox(height: 16),

            const Text('2. Calories'),
            const SizedBox(height: 6),
            _inputField(
              _calorieController,
              'Enter calories',
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 16),

            const Text('3. Date'),
            const SizedBox(height: 6),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    ),
                    const Icon(Icons.calendar_month),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6FA89A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _saveMeal,
                child: Text(
                  _editingIndex == null ? 'Add Meal' : 'Update Meal',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(
      TextEditingController controller,
      String hint, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveMeal() {
    if (_nameController.text.isEmpty ||
        _calorieController.text.isEmpty) return;

    final meal = Meal(
      id: '',
      name: _nameController.text,
      calories: int.parse(_calorieController.text),
      date: _selectedDate,
    );

    final provider = Provider.of<MealProvider>(context, listen: false);

    if (_editingIndex == null) {
      provider.addMeal(meal);
    } else {
      provider.updateMeal(
        _editingDocId!,
        _editingIndex!,
        meal,
      );
      _editingIndex = null;
      _editingDocId = null;
    }

    _nameController.clear();
    _calorieController.clear();
  }
}

