import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart';
import '../../routes/app_routes.dart';

class MainScaffold extends StatefulWidget {
  final Widget body;
  final String? title;
  final List<Widget>? actions;
  final int currentNavIndex;

  const MainScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.currentNavIndex = 0,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.workout);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.meal);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.reminders);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.water);
        break;
      case 4:
        Navigator.pushReplacementNamed(context, AppRoutes.measurements);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.title != null
          ? AppBar(
              title: Text(widget.title!),
              actions: widget.actions,
            )
          : null,
      body: widget.body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: widget.currentNavIndex,
        onTap: _onNavTap,
      ),
    );
  }
}


