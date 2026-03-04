import 'package:flutter/material.dart';
import '../widgets/app_bar.dart';

class KonfiguracjaPage extends StatefulWidget {
  const KonfiguracjaPage({super.key});

  @override
  State<KonfiguracjaPage> createState() => _KonfiguracjaPageState();
}

class _KonfiguracjaPageState extends State<KonfiguracjaPage> {
  bool _twoFactorAuth = true;
  bool _sessionTimeout = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _weeklyReports = true;
  bool _autoPlaning = false;
  bool _allowEditsByManagers = true;
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, 'Konfiguracja'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Bezpieczeństwo',
            icon: Icons.security,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Wymagaj 2FA przy logowaniu'),
                value: _twoFactorAuth,
                onChanged: (value) => setState(() => _twoFactorAuth = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Automatyczne wylogowanie po bezczynności'),
                value: _sessionTimeout,
                onChanged: (value) => setState(() => _sessionTimeout = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Powiadomienia',
            icon: Icons.notifications_active,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Powiadomienia e-mail o nowych wnioskach'),
                value: _emailNotifications,
                onChanged: (value) =>
                    setState(() => _emailNotifications = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Powiadomienia SMS dla kierowników'),
                value: _smsNotifications,
                onChanged: (value) => setState(() => _smsNotifications = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cotygodniowe raporty systemowe'),
                value: _weeklyReports,
                onChanged: (value) => setState(() => _weeklyReports = value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Procesy i system',
            icon: Icons.settings_suggest,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Automatyczne planowanie grafików'),
                value: _autoPlaning,
                onChanged: (value) => setState(() => _autoPlaning = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Zezwól kierownikom na edycję wniosków'),
                value: _allowEditsByManagers,
                onChanged: (value) =>
                    setState(() => _allowEditsByManagers = value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tryb serwisowy systemu'),
                value: _maintenanceMode,
                onChanged: (value) => setState(() => _maintenanceMode = value),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}
