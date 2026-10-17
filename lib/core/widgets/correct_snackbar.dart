import 'package:flutter/material.dart';

class CucSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        IconData icon = Icons.check_circle_outline,
        Color? iconColor,
      }) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? colorScheme.primary;

    // Limpia cualquier SnackBar activo previo para evitar acumulaciones en cola
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: colorScheme.surfaceContainerHighest,
        content: Row(
          children: [
            Icon(icon, color: effectiveIconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}