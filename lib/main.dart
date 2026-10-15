import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pokemon/l10n/app_localizations.dart';

import 'di/injection.dart';
import 'router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const _lightCupertinoTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.activeBlue,
  );

  static const _darkCupertinoTheme = CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: CupertinoColors.activeBlue,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        platform: TargetPlatform.iOS,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        platform: TargetPlatform.iOS,
        brightness: Brightness.dark,
      ),
      builder: (context, child) {
        final brightness = MediaQuery.platformBrightnessOf(context);
        final cupertinoTheme = brightness == Brightness.dark
            ? _darkCupertinoTheme
            : _lightCupertinoTheme;

        return CupertinoTheme(
          data: cupertinoTheme,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
