import 'package:flutter/material.dart';
import 'dart:ui'; // For blur effect

/// Simple glass effect card widget
/// This creates a semi-transparent card with blur effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius!),
      child: BackdropFilter(
        // This creates the blur effect
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            // Semi-transparent white background
            color: Colors.white.withOpacity(0.2),
            // Border for better visibility
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(borderRadius!),
          ),
          child: child,
        ),
      ),
    );
  }
}

