import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vehicle_service_manager_frontend/core/constants.dart';
import 'package:vehicle_service_manager_frontend/core/router.dart';
import 'package:vehicle_service_manager_frontend/core/theme.dart';
import 'package:vehicle_service_manager_frontend/providers/app_state_provider.dart';
import 'package:vehicle_service_manager_frontend/providers/theme_provider.dart';

class VehicleServiceManagerApp extends StatelessWidget {
  VehicleServiceManagerApp({super.key})
      : _router = createRouter(
          shellBuilder: (
            BuildContext context,
            GoRouterState state,
            Widget child,
          ) {
            return ResponsiveAppShell(state: state, child: child);
          },
        );

  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    return MaterialApp.router(
      title: 'Fahrzeug-Service-Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
    );
  }
}

class ResponsiveAppShell extends StatelessWidget {
  const ResponsiveAppShell({
    required this.state,
    required this.child,
    super.key,
  });

  final GoRouterState state;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = context.watch<ThemeProvider>();
    final AppStateProvider appState = context.watch<AppStateProvider>();
    final bool isMobile =
        MediaQuery.of(context).size.width < kTabletBreakpoint;
    final int selectedIndex = _selectedIndex(state.uri.toString());
    final String title = _items[selectedIndex].label;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text(title),
        flexibleSpace: const DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xFF8B0000),
                Color(0xFFB0B0B8),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.directions_car, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Autohaus Rabus',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        actions: <Widget>[
          if (appState.isCheckingConnectivity)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          IconButton(
            tooltip: themeProvider.isDarkMode
                ? 'Hellen Modus verwenden'
                : 'Dunklen Modus verwenden',
            onPressed: themeProvider.toggle,
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
          ),
          IconButton(
            tooltip: 'Backend-Status aktualisieren',
            onPressed: appState.refreshConnectivity,
            icon: const Icon(Icons.cloud_sync_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            if (appState.isDemoMode) const _DemoModeBanner(),
            Expanded(
              child: isMobile
                  ? child
                  : Row(
                      children: <Widget>[
                        NavigationRail(
                          selectedIndex: selectedIndex,
                          extended:
                              MediaQuery.of(context).size.width >=
                                  kDesktopBreakpoint,
                          onDestinationSelected: (int index) {
                            context.go(_items[index].route);
                          },
                          destinations: _items
                              .map(
                                (_NavItem item) => NavigationRailDestination(
                                  icon: Icon(item.icon),
                                  label: Text(item.label),
                                ),
                              )
                              .toList(),
                        ),
                        const VerticalDivider(width: 1),
                        Expanded(child: child),
                      ],
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (int index) {
                context.go(_items[index].route);
              },
              destinations: _items
                  .map(
                    (_NavItem item) => NavigationDestination(
                      icon: Icon(item.icon),
                      label: item.label,
                    ),
                  )
                  .toList(),
            )
          : null,
    );
  }

  int _selectedIndex(String location) {
    if (location.startsWith('/vehicles')) {
      return 1;
    }
    if (location.startsWith('/maintenance')) {
      return 2;
    }
    if (location.startsWith('/documents')) {
      return 3;
    }
    if (location.startsWith('/reminders')) {
      return 4;
    }
    return 0;
  }
}

class _DemoModeBanner extends StatelessWidget {
  const _DemoModeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Row(
        children: <Widget>[
          const Icon(Icons.offline_bolt_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Demo-Modus ist aktiv. Daten werden lokal in Ihrem Browser gespeichert.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.label,
    required this.route,
    required this.icon,
  });

  final String label;
  final String route;
  final IconData icon;
}

const List<_NavItem> _items = <_NavItem>[
  _NavItem(label: 'Übersicht', route: '/', icon: Icons.dashboard_outlined),
  _NavItem(label: 'Fahrzeuge', route: '/vehicles', icon: Icons.directions_car),
  _NavItem(
    label: 'Wartung',
    route: '/maintenance',
    icon: Icons.build_circle_outlined,
  ),
  _NavItem(label: 'Dokumente', route: '/documents', icon: Icons.folder_copy_outlined),
  _NavItem(label: 'Erinnerungen', route: '/reminders', icon: Icons.notifications_active_outlined),
];
