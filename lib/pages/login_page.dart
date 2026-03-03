import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../data/demo_data.dart';
import '../globals.dart';
import 'start_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  void _login(Employee employee) {
    loggedInEmployee = employee;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const StartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Logowanie'),
      ),
      body: ListView.builder(
        itemCount: demoEmployees.length,
        itemBuilder: (context, index) {
          final employee = demoEmployees[index];
          return ListTile(
            leading: const Icon(Icons.person),
            title: Text(employee.name),
            subtitle: Text(employee.position),
            onTap: () => _login(employee),
          );
        },
      ),
    );
  }
}
