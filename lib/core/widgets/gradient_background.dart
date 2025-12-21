import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Simple gradient background widget
/// Use this to wrap your screen content
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradientTeal, // Lighter teal at top
            AppColors.gradientBlue, // Deeper blue at bottom
          ],
        ),
      ),
      child: child,
    );
  }
}

