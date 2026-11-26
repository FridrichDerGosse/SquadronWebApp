import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import 'pages/server_status_page.dart';
import 'pages/overview_page.dart';
import 'pages/login_page.dart';
import 'pages/app_page.dart';
import 'misc/auth_session.dart';


void main()
{
  runApp(const MyApp());
}

class MyApp extends StatefulWidget
{
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>
{
  ThemeMode _themeMode = ThemeMode.system;

  bool get _isDark {
    return _themeMode == ThemeMode.dark ||
        (_themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
  }

  void _toggleTheme() {
    setState(() {
      _themeMode = _isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Squadron',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 103),
          brightness: Brightness.light
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 0, 255, 103),
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      home: SidebarShell(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}


class SidebarShell extends StatefulWidget
{
  final bool isDark;
  final VoidCallback onToggleTheme;

  const SidebarShell({
    super.key,
    required this.isDark,
    required this.onToggleTheme
  });

  @override
  State<SidebarShell> createState() => _SidebarShellState();
}

class _SidebarShellState extends State<SidebarShell> {
  final _squadronGithub = Uri.parse('https://github.com/FridrichDerGosse/SquadronServer/blob/main/protocol.md');

  bool _isExpanded = true;
  int _selectedIndex = 0;

  final List<_NavFrame> _frames = const [
    _NavFrame(
      title: 'Overview',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      page: OverviewPage(),
    ),
    _NavFrame(
      title: 'App',
      icon: Icons.monitor_heart_outlined,
      selectedIcon: Icons.monitor_heart_rounded,
      page: AppPage(),
      requiresAuth: true,
    ),
    _NavFrame(
      title: 'Server Status',
      icon: Icons.dns_outlined,
      selectedIcon: Icons.dns,
      page: ServerStatusPage(),
    ),
    _NavFrame(
      title: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      page: OverviewPage(),
      requiresAuth: true,
    ),
  ];

  Future<void> _openSquadronLink() async {
    try {
      final opened = await launchUrl(
        _squadronGithub,
        webOnlyWindowName: '_blank',
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link')),
        );
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeFrame = _frames[_selectedIndex];
    final themeIcon = widget.isDark ? Icons.light_mode : Icons.dark_mode;
    final themeLabel = widget.isDark ? "Light Mode" : "Dark Mode";
    final isLocked = activeFrame.requiresAuth && !AuthSession.isLoggedIn;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: _isExpanded,
            selectedIndex: _selectedIndex,
            backgroundColor: colorScheme.surfaceContainerLow,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            leading: Column(
              children: [
                const SizedBox(height: 12),
                IconButton(
                  tooltip: _isExpanded ? 'Collapse sidebar' : 'Expand sidebar',
                  icon: Icon(_isExpanded ? Icons.menu_open : Icons.menu),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
                const SizedBox(height: 8),
                _isExpanded
                    ? TextButton.icon(
                        onPressed: _openSquadronLink,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Squadron'),
                      )
                    : IconButton(
                        tooltip: 'Squadron (GitHub)',
                        onPressed: _openSquadronLink,
                        icon: const Icon(Icons.code),
                      ),
                const SizedBox(height: 8),
              ],
            ),
            destinations: [
              for (final frame in _frames)
                NavigationRailDestination(
                  icon: Icon(frame.icon),
                  selectedIcon: Icon(frame.selectedIcon),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(child: Text(frame.title, overflow: TextOverflow.ellipsis)),
                      if (frame.requiresAuth && !AuthSession.isLoggedIn) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.lock_outline, size: 16),
                      ],
                    ],
                  ),
                ),
            ],
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _isExpanded
                    ? TextButton.icon(
                      onPressed: widget.onToggleTheme,
                      icon: Icon(themeIcon, size: 18),
                      label: Text(themeLabel),
                    )
                    : IconButton(
                      tooltip: themeLabel,
                      onPressed: widget.onToggleTheme,
                      icon: Icon(themeIcon)
                    )
                  )
              )
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1140),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: isLocked
                    ? LoginPage()
                    : activeFrame.page,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _NavFrame {
  final String title;
  final IconData icon;
  final IconData selectedIcon;
  final Widget page;
  final bool requiresAuth;

  const _NavFrame({
    required this.title,
    required this.icon,
    required this.selectedIcon,
    required this.page,
    this.requiresAuth = false,
  });
}
