import 'package:flutter/material.dart';
import '../globals.dart';
import '../pages/login_page.dart';
import '../pages/start_page.dart';
import '../pages/pracownicy_page.dart';
import '../pages/hr_page.dart';
import '../pages/rcp_page.dart';

PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        if (loggedInEmployee != null)
          Text(
            'Zalogowany: ${loggedInEmployee!.name}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const StartPage()),
          );
        },
        child: const Text('Start', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const PracownicyPage()),
          );
        },
        child: const Text('Pracownicy', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HRPage()),
          );
        },
        child: const Text('HR', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const RCPPage()),
          );
        },
        child: const Text('RCP', style: TextStyle(color: Colors.black)),
      ),
      TextButton(
        onPressed: () {
          loggedInEmployee = null;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
        child: const Text('Wyloguj', style: TextStyle(color: Colors.red)),
      ),
    ],
  );
}
