import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'globals.dart';
import 'data/demo_data.dart';
import 'pages/login_page.dart';
import 'pages/start_page.dart';

Future<void> main() async {
  await dotenv.load();
  geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  employees = List.from(demoEmployees);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
        home: loggedInEmployee == null
          ? const LoginPage()
          : const StartPage(),
    );
  }
}

