import 'package:flutter/material.dart';
import '../widgets/navigation_menu.dart';
import 'dashboard_page.dart';

class BmiPage extends StatefulWidget {
  const BmiPage({super.key});

  @override
  State<BmiPage> createState() => _BmiPageState();
}

class _BmiPageState extends State<BmiPage> {
  final _formKey = GlobalKey<FormState>();
  final heightController = TextEditingController(); // in cm
  final weightController = TextEditingController(); // in kg

  double? _bmi;
  String _category = "";

  void _calculateBmi() {
    if (_formKey.currentState!.validate()) {
      final hCm = double.parse(heightController.text);
      final wKg = double.parse(weightController.text);

      if (hCm <= 0) return;

      final hM = hCm / 100.0;
      final bmi = wKg / (hM * hM);

      String cat;
      if (bmi < 18.5) {
        cat = "Underweight";
      } else if (bmi < 25) {
        cat = "Normal";
      } else if (bmi < 30) {
        cat = "Overweight";
      } else {
        cat = "Obese";
      }

      setState(() {
        _bmi = double.parse(bmi.toStringAsFixed(1));
        _category = cat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF004AAD), Color(0xFFCB6CE6)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            },
          ),
          title: const Text(
            "BMI Calculator",
            style: TextStyle(
              fontFamily: "TheSeason",
              fontWeight: FontWeight.w700,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
        ),
        // you can choose whether to show nav; here I keep it off-nav feature
        // bottomNavigationBar: const NavigationMenu(selectedIndex: 0),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text(
                  "Enter your details",
                  style: TextStyle(
                    fontFamily: "TheSeason",
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: heightController,
                  decoration: const InputDecoration(
                    labelText: "Height (cm)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter height" : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: "Weight (kg)",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Enter weight" : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF004AAD), Color(0xFFCB6CE6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ElevatedButton(
                      onPressed: _calculateBmi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Calculate BMI",
                        style: TextStyle(
                          fontFamily: "TheSeason",
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_bmi != null)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFE1BEE7),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Your BMI",
                            style: TextStyle(
                              fontFamily: "TheSeason",
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _bmi!.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _category,
                            style: const TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
