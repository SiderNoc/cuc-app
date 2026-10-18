import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_routes.dart';
import 'features/profile/providers/profile_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    throw Exception(
      'Error: No se encontro el archivo .env. Asegurate de crearlo en la raiz del proyecto.',
    );
  }

  final supabaseUrl = dotenv.env['SUPABASE_URL']?.trim() ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim() ?? '';

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw Exception(
      'Error: SUPABASE_URL y SUPABASE_ANON_KEY deben existir en el archivo .env.',
    );
  }

  final parsedSupabaseUrl = Uri.tryParse(supabaseUrl);
  if (parsedSupabaseUrl == null ||
      !parsedSupabaseUrl.hasScheme ||
      !parsedSupabaseUrl.hasAuthority) {
    throw Exception(
      'Error: SUPABASE_URL debe ser una URL completa, por ejemplo https://tu-proyecto.supabase.co.',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const ProviderScope(child: CucApp()));
}

class CucApp extends ConsumerWidget {
  const CucApp({super.key});

// En tu archivo lib/main.dart, dentro de CucApp:

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final accState = ref.watch(accessibilityProvider);

    // Mantenemos solo la escala de texto con limite 1.2
    final double safeTextScale = accState.escalaTexto.clamp(1.0, 1.2);

    return MaterialApp.router(
      title: 'CUC App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark, // Restaurado al tema estatico original

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'MX'),
        Locale('en', 'US'),
      ],
      routerConfig: router,

      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: TextScaler.linear(safeTextScale),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}