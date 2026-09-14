import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_shell.dart';
import 'features/onboarding/onboarding_page.dart';
import 'services/biometric_service.dart';
import 'state/app_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.init();
  runApp(
    ChangeNotifierProvider.value(
      value: store,
      child: const MoedApp(),
    ),
  );
}

class MoedApp extends StatelessWidget {
  const MoedApp({super.key});

  @override
  Widget build(BuildContext context) {
    // فقط تنظیماتی که واقعاً ساختار ریشه را تغییر می‌دهند گوش می‌شوند.
    // قبلاً watch کل AppStore باعث می‌شد هر پرداخت/رفرش، MaterialApp و Navigator
    // دوباره ساخته شوند و در Web به assertion مربوط به InheritedElement برسیم.
    final themeMode = context.select<AppStore, String>(
      (store) => store.settings.themeMode,
    );
    final onboarded = context.select<AppStore, bool>(
      (store) => store.settings.onboarded,
    );
    final biometric = context.select<AppStore, bool>(
      (store) => store.settings.biometric,
    );
    final store = context.read<AppStore>();

    final mode = switch (themeMode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'موعد',
      locale: const Locale('fa'),
      supportedLocales: const [Locale('fa'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: mode,
      builder: (context, child) {
        final content = Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
        if (!kIsWeb) return content;
        return ColoredBox(
          color: const Color(0xFFE7F0FF),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: content,
            ),
          ),
        );
      },
      home: !onboarded
          ? OnboardingPage(onDone: store.completeOnboarding)
          : biometric
              ? const _LockGate()
              : const HomeShell(),
    );
  }
}

class _LockGate extends StatefulWidget {
  const _LockGate();
  @override
  State<_LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<_LockGate> {
  bool ok = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unlock());
  }

  Future<void> unlock() async {
    final result = await BiometricService().authenticate();
    if (mounted) setState(() => ok = result);
  }

  @override
  Widget build(BuildContext context) => ok
      ? const HomeShell()
      : Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_rounded, size: 58),
                const SizedBox(height: 16),
                const Text(
                  'موعد قفل است',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: unlock,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('باز کردن'),
                ),
              ],
            ),
          ),
        );
}
