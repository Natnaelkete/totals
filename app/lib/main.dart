import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:totals/providers/transaction_provider.dart';
import 'package:totals/screens/home_page.dart';
import 'package:totals/services/sms_service.dart'; // Import for onBackgroundMessage if needed for some plugins, but here mostly for side effects if any.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Totals',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}
