import 'package:flutter/material.dart';
import '../globals.dart';
import 'kierownik_page.dart';
import 'konfiguracja_page.dart';
import 'pracownicy_page.dart';
import 'rcp_page.dart';
import '../widgets/app_bar.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final List<_DashboardModule> _modules = const [
    _DashboardModule(
      title: 'Pracownik',
      subtitle: 'Twoje konto pracownika',
      icon: Icons.person,
      accent: Color(0xFFC8BAFF),
      type: _ModuleType.pracownicy,
    ),
    _DashboardModule(
      title: 'HR',
      subtitle: 'Zarządzaj działem HR',
      icon: Icons.groups,
      accent: Color(0xFFA3E5BF),
      type: _ModuleType.hr,
    ),
    _DashboardModule(
      title: 'Kierownik',
      subtitle: 'Zarządzaj wnioskami swoich pracowników',
      icon: Icons.manage_accounts,
      accent: Color(0xFFF2DE8C),
      type: _ModuleType.kierownik,
    ),
    _DashboardModule(
      title: 'Planowanie',
      subtitle: 'Układaj grafiki dla swoich pracowników',
      icon: Icons.calendar_month,
      accent: Color(0xFF9CE0E8),
      type: _ModuleType.comingSoon,
    ),
    _DashboardModule(
      title: 'RCP',
      subtitle: 'Rozliczenie czasu pracy',
      icon: Icons.access_time,
      accent: Color(0xFFF4B08E),
      type: _ModuleType.rcp,
    ),
    _DashboardModule(
      title: 'Raporty',
      subtitle: 'Możliwość generowania raportów i zestawień z systemu.',
      icon: Icons.description,
      accent: Color(0xFFD7E2A6),
      type: _ModuleType.comingSoon,
    ),
    _DashboardModule(
      title: 'Konfiguracja',
      subtitle: 'Ustawienia systemowe, zarządzanie systemem',
      icon: Icons.settings,
      accent: Color(0xFFF3A8B8),
      type: _ModuleType.konfiguracja,
    ),
  ];

  void _openModule(_DashboardModule module) {
    switch (module.type) {
      case _ModuleType.pracownicy:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PracownicyPage()));
        break;
      case _ModuleType.hr:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PracownicyPage()));
        break;
      case _ModuleType.kierownik:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const KierownikPage()));
        break;
      case _ModuleType.rcp:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const RCPPage()));
        break;
      case _ModuleType.konfiguracja:
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const KonfiguracjaPage()));
        break;
      case _ModuleType.comingSoon:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ta sekcja będzie dostępna w kolejnej wersji.'),
          ),
        );
        break;
    }
  }

  Widget _buildProfileHeader(double width) {
    final employee = loggedInEmployee;
    final name = employee?.name ?? 'Użytkownik';
    final role = employee?.position ?? 'Administrator';
    final initials = name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.substring(0, 1).toUpperCase())
        .join();
    final compact = width < 760;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: compact ? 22 : 26,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: TextStyle(
                fontSize: compact ? 16 : 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(width: compact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 22 : 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: compact ? 15 : 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(_DashboardModule module, double cardWidth, bool compact) {
    return SizedBox(
      width: cardWidth,
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openModule(module),
          child: Container(
            constraints: BoxConstraints(minHeight: compact ? 126 : 148),
            padding: EdgeInsets.all(compact ? 14 : 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: module.accent, width: 6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      module.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: compact ? 8 : 10),
                    Expanded(
                      child: Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: compact ? 24 : 34,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  module.subtitle,
                  style: TextStyle(
                    fontSize: compact ? 16 : 20,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLayout(double width) {
    const gap = 12.0;
    final compact = width < 760;

    if (width < 760) {
      return Column(
        children: [
          for (var i = 0; i < _modules.length; i++) ...[
            _buildCard(_modules[i], width, compact),
            if (i != _modules.length - 1) const SizedBox(height: gap),
          ],
        ],
      );
    }

    if (width < 1180) {
      final cardWidth = (width - gap) / 2;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final module in _modules) _buildCard(module, cardWidth, compact),
        ],
      );
    }

    final wide = (width - gap) / 2;
    final third = (width - (2 * gap)) / 3;
    return Column(
      children: [
        Row(
          children: [
            _buildCard(_modules[0], wide, compact),
            const SizedBox(width: gap),
            _buildCard(_modules[1], wide, compact),
          ],
        ),
        const SizedBox(height: gap),
        Row(
          children: [
            _buildCard(_modules[2], wide, compact),
            const SizedBox(width: gap),
            _buildCard(_modules[3], wide, compact),
          ],
        ),
        const SizedBox(height: gap),
        Row(
          children: [
            _buildCard(_modules[4], third, compact),
            const SizedBox(width: gap),
            _buildCard(_modules[5], third, compact),
            const SizedBox(width: gap),
            _buildCard(_modules[6], third, compact),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = 16.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      appBar: buildAppBar(context, 'Start'),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final contentWidth = maxWidth > 1200 ? 1200.0 : maxWidth;
            final innerContentWidth = (contentWidth - (horizontalPadding * 2))
                .clamp(0.0, double.infinity);

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    horizontalPadding,
                    16,
                    horizontalPadding,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileHeader(innerContentWidth),
                      const SizedBox(height: 14),
                      _buildLayout(innerContentWidth),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ModuleType { pracownicy, hr, kierownik, rcp, konfiguracja, comingSoon }

class _DashboardModule {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final _ModuleType type;

  const _DashboardModule({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.type,
  });
}
