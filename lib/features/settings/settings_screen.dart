import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cuc_app_bar.dart';
import '../profile/providers/profile_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accState = ref.watch(accessibilityProvider);
    final notifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CucAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'ACCESIBILIDAD',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tamano del Texto'),
                  const SizedBox(height: 8),
                  Slider(
                    value: accState.escalaTexto,
                    min: 1.0,
                    max: 1.2,
                    divisions: 2,
                    label: '${(accState.escalaTexto * 100).toInt()}%',
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      notifier.updateLocal(false, val); // Forzamos false en contraste
                    },
                    onChangeEnd: (val) {
                      notifier.saveToDatabase();
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SESIÓN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              await ref.read(authServiceProvider).cerrarSesion();
            },
            icon: const Icon(Icons.logout),
            label: const Text('CERRAR SESIÓN'),
          ),
        ],
      ),
    );
  }
}