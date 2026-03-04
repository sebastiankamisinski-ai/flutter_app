import 'package:flutter/material.dart';
import '../globals.dart';
import '../pages/login_page.dart';
import '../pages/start_page.dart';
import '../pages/pracownicy_page.dart';
import '../pages/rcp_page.dart';
import '../pages/konfiguracja_page.dart';

PreferredSizeWidget buildAppBar(BuildContext context, String title) {
  void navigateTo(_NavTarget target) {
    switch (target) {
      case _NavTarget.start:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const StartPage()),
        );
        break;
      case _NavTarget.pracownicy:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PracownicyPage()),
        );
        break;
      case _NavTarget.hr:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PracownicyPage()),
        );
        break;
      case _NavTarget.rcp:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RCPPage()),
        );
        break;
      case _NavTarget.konfiguracja:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const KonfiguracjaPage()),
        );
        break;
      case _NavTarget.logout:
        loggedInEmployee = null;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        break;
    }
  }

  Widget navButton(String label, _NavTarget target, {Color? color}) {
    return TextButton(
      onPressed: () => navigateTo(target),
      child: Text(
        label,
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }

  final screenWidth = MediaQuery.of(context).size.width;
  final estimatedTitleWidth = loggedInEmployee == null ? 180.0 : 320.0;
  const estimatedActionsWidth = 540.0;
  const appBarHorizontalPadding = 32.0;
  final isCompact =
      screenWidth <
      (estimatedTitleWidth + estimatedActionsWidth + appBarHorizontalPadding);

  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        if (loggedInEmployee != null)
          Text(
            'Zalogowany: ${loggedInEmployee!.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
      ],
    ),
    actions: isCompact
        ? [
            PopupMenuButton<_NavTarget>(
              icon: Icon(
                Icons.more_vert,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onSelected: navigateTo,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _NavTarget.start, child: Text('Start')),
                PopupMenuItem(
                  value: _NavTarget.pracownicy,
                  child: Text('Pracownicy'),
                ),
                PopupMenuItem(value: _NavTarget.hr, child: Text('HR')),
                PopupMenuItem(value: _NavTarget.rcp, child: Text('RCP')),
                PopupMenuItem(
                  value: _NavTarget.konfiguracja,
                  child: Text('Konfiguracja'),
                ),
                PopupMenuItem(value: _NavTarget.logout, child: Text('Wyloguj')),
              ],
            ),
          ]
        : [
            navButton('Start', _NavTarget.start),
            navButton('Pracownicy', _NavTarget.pracownicy),
            navButton('HR', _NavTarget.hr),
            navButton('RCP', _NavTarget.rcp),
            navButton('Konfiguracja', _NavTarget.konfiguracja),
            navButton(
              'Wyloguj',
              _NavTarget.logout,
              color: Theme.of(context).colorScheme.errorContainer,
            ),
          ],
  );
}

enum _NavTarget { start, pracownicy, hr, rcp, konfiguracja, logout }
