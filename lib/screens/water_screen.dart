import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';

class WaterScreen extends StatefulWidget {
  const WaterScreen({super.key});

  static const Color primaryGreen = Color(0xFF7FAFA3);
  static const Color lightGreen = Color(0xFFE6F1EE);

  @override
  State<WaterScreen> createState() => _WaterScreenState();
}

class _WaterScreenState extends State<WaterScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<WaterProvider>(context, listen: false)
        .fetchWaterFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'WATER INTAKE TRACKER 💧',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: WaterScreen.primaryGreen,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: WaterScreen.primaryGreen,
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: WaterScreen.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Consumed',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${provider.total} ml',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Water Records',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: provider.entries.isEmpty
                  ? const Center(child: Text('No records yet'))
                  : ListView.builder(
                itemCount: provider.entries.length,
                itemBuilder: (context, index) {
                  final item = provider.entries[index];
                  final date = item['date'] as DateTime;

                  return Card(
                    color: WaterScreen.lightGreen,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.water_drop,
                        color: WaterScreen.primaryGreen,
                      ),
                      title: Text(
                        '${item['amount']} ml',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: WaterScreen.primaryGreen,
                            ),
                            onPressed: () => _showEditDialog(
                              context,
                              index,
                              item['amount'],
                              date,
                              item['id'],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () =>
                                provider.deleteWater(item['id'], index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Water'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Water (ml)',
            filled: true,
            fillColor: WaterScreen.lightGreen,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WaterScreen.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.addWater(
                int.parse(controller.text),
                DateTime.now(),
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      BuildContext context,
      int index,
      int oldAmount,
      DateTime date,
      String docId,
      ) {
    final provider = Provider.of<WaterProvider>(context, listen: false);
    final controller = TextEditingController(text: oldAmount.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Water'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Water (ml)',
            filled: true,
            fillColor: WaterScreen.lightGreen,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: WaterScreen.primaryGreen,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              provider.editWater(
                docId,
                index,
                int.parse(controller.text),
                date,
              );
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
