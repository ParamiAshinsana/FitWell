import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.6),
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.fitness_center),
                label: 'Workout',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant),
                label: 'Meals',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.medication),
                label: 'Medicines',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.water_drop),
                label: 'Water',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: 'Progress',
              ),
            ],
          ),
        ),
      ),
    );
  }
}


