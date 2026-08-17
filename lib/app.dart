import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'view_models/app_settings_view_model.dart';

class SpendlyApp extends StatefulWidget {
  const SpendlyApp({super.key, required this.settings});

  final AppSettingsViewModel settings;

  @override
  State<SpendlyApp> createState() => _SpendlyAppState();
}

class _SpendlyAppState extends State<SpendlyApp> {
  late final AppRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter(widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settings,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Spendly',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: widget.settings.themeMode,
          locale: widget.settings.locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router.router,
        );
      },
    );
  }
}
