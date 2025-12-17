import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totals/providers/insights_provider.dart';
import 'package:totals/providers/theme_provider.dart';
import 'package:totals/providers/transaction_provider.dart';
import 'package:totals/screens/home_page.dart';
import 'package:totals/services/account_sync_status_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database and migrate if needed
  // await MigrationHelper.migrateIfNeeded();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),

        // we need insights provider to use the existing transacton provider instead of using
        // a new transaction provider instance.
        ChangeNotifierProxyProvider<TransactionProvider, InsightsProvider>(
          create: (context) => InsightsProvider(
              txProvider:
                  Provider.of<TransactionProvider>(context, listen: false)),
          update: (context, txProvider, previous) =>
              previous!..txProvider = txProvider,
        ),
        ChangeNotifierProvider.value(value: AccountSyncStatusService.instance),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Totals',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
            ),
            darkTheme: ThemeData(
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF294EC3),
                secondary: Color(0xFF3B5FE8),
                surface: Color(0xFF0A0E1A),
                background: Color(0xFF0A0E1A),
                surfaceVariant: Color(0xFF1A1F2E),
                onPrimary: Colors.white,
                onSecondary: Colors.white,
                onSurface: Colors.white,
                onBackground: Colors.white,
                onSurfaceVariant: Colors.white70,
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0A0E1A),
              cardColor: const Color(0xFF1A1F2E),
              dividerColor: const Color(0xFF2A2F3E),
              useMaterial3: true,
            ),
            themeMode: themeProvider.themeMode,
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
