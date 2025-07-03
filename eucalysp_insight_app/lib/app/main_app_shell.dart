// lib/app/main_app_shell.dart
import 'package:eucalysp_insight_app/app/core/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/core/services/layout_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eucalysp_insight_app/app/app_theme.dart'; // Import for AppThemeColors

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({required this.child, super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  // Define all possible navigation routes and their corresponding indices.
  // This will be the master list from which mobile/desktop menus are derived.
  static const List<String> _primaryRoutes = [
    '/dashboard',
    '/inventory',
    '/sales',
    '/reports', // New: Reports
    '/settings', // New: Settings
  ];

  // Routes that might go into an "Other" menu on desktop for overflow
  static const List<String> _otherRoutes = [
    '/profile', // Example: User Profile
    '/help', // Example: Help/Support
    '/about', // Example: About App
  ];

  // Helper to determine the current index based on the GoRouter's current location
  void _updateNavigationIndexFromRoute(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    int newIndex;

    // Determine index for primary navigation items
    int foundIndex = _primaryRoutes.indexWhere(
      (route) => location.startsWith(route),
    );
    if (foundIndex != -1) {
      newIndex = foundIndex;
    } else {
      // If not in primary, check if it's in the 'other' routes
      // We'll give 'other' routes a special index or handle them separately
      // For now, let's make sure our primary navigation doesn't accidentally
      // highlight an 'other' route.
      newIndex = 0; // Default to dashboard if not a primary route
    }

    context.read<NavigationCubit>().updateIndex(newIndex);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationIndexFromRoute(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateNavigationIndexFromRoute(context);
  }

  // Corrected _onItemTapped signature to accept BuildContext
  void _onItemTapped(int index, BuildContext context) {
    context.read<NavigationCubit>().updateIndex(index);
    if (index >= 0 && index < _primaryRoutes.length) {
      context.go(_primaryRoutes[index]);
    }
  }

  // Method to handle navigation for 'Other' menu items
  void _onOtherItemTapped(String route, BuildContext context) {
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final bool useMobileLayout = LayoutService.isMobileLayout(context);
    final AppThemeColors appColors = Theme.of(
      context,
    ).extension<AppThemeColors>()!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Provide the NavigationCubit here and listen to its state
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, selectedIndex) {
          if (useMobileLayout) {
            // --- Mobile Layout ---
            // Max 4 items for BottomNavigationBar.
            // Adjust _primaryRoutes to only include the first 3 or 4 for mobile.
            // Example: Dashboard, Inventory, Sales
            final List<BottomNavigationBarItem> mobileItems = const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.inventory_2_outlined),
                activeIcon: Icon(Icons.inventory_2),
                label: 'Inventory',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Sales',
              ),
              // You can add a fourth item here if desired, e.g., 'Reports'
              // BottomNavigationBarItem(
              //   icon: Icon(Icons.bar_chart_outlined),
              //   activeIcon: Icon(Icons.bar_chart),
              //   label: 'Reports',
              // ),
            ];

            return Scaffold(
              appBar: AppBar(
                title: const Text('EucalyspInsight'),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              body: widget.child,
              bottomNavigationBar: BottomNavigationBar(
                items: mobileItems,
                currentIndex: selectedIndex,
                onTap: (index) {
                  // Ensure mobile onTap only navigates to routes available in mobileItems
                  if (index < mobileItems.length) {
                    _onItemTapped(index, context);
                  }
                },
                type: BottomNavigationBarType.fixed, // Use fixed for 3-5 items
                selectedItemColor:
                    colorScheme.primary, // Primary color for selected item
                unselectedItemColor:
                    colorScheme.onSurfaceVariant, // Muted for unselected
                backgroundColor: colorScheme.surface, // Background of the bar
              ),
            );
          } else {
            // --- Desktop/Web Layout ---
            // NavigationRail can accommodate more items.
            // We'll create the primary NavigationRail items and then an "Other" menu.
            final List<NavigationRailDestination> primaryDesktopDestinations = [
              NavigationRailDestination(
                icon: Icon(
                  Icons.dashboard_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                selectedIcon: Icon(Icons.dashboard, color: colorScheme.primary),
                label: const Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                selectedIcon: Icon(
                  Icons.inventory_2,
                  color: colorScheme.primary,
                ),
                label: const Text('Inventory'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                selectedIcon: Icon(
                  Icons.shopping_cart,
                  color: colorScheme.primary,
                ),
                label: const Text('Sales'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.bar_chart_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                selectedIcon: Icon(Icons.bar_chart, color: colorScheme.primary),
                label: const Text('Reports'),
              ),
              NavigationRailDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colorScheme.onSurfaceVariant,
                ),
                selectedIcon: Icon(Icons.settings, color: colorScheme.primary),
                label: const Text('Settings'),
              ),
            ];

            return Scaffold(
              appBar: AppBar(
                title: const Text('EucalyspInsight'),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              body: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) =>
                        _onItemTapped(index, context),
                    labelType: NavigationRailLabelType.all,
                    destinations: primaryDesktopDestinations,
                    // Style NavigationRail
                    backgroundColor: colorScheme.surface,
                    indicatorColor: colorScheme.primaryContainer,
                    selectedIconTheme: IconThemeData(
                      color: colorScheme.primary,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    selectedLabelTextStyle: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const VerticalDivider(
                    thickness: 1,
                    width: 1,
                  ), // A subtle divider
                  Expanded(child: widget.child),
                  // "Other" Menu for Desktop
                  Align(
                    alignment: Alignment
                        .bottomLeft, // Align to bottom of NavigationRail
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16.0,
                        left: 8.0,
                      ), // Padding from bottom and left
                      child: PopupMenuButton<String>(
                        onSelected: (String result) {
                          _onOtherItemTapped(result, context);
                        },
                        itemBuilder: (BuildContext context) => _otherRoutes.map(
                          (route) {
                            String title =
                                route.substring(1)[0].toUpperCase() +
                                route.substring(2); // Simple capitalization
                            return PopupMenuItem<String>(
                              value: route,
                              child: Text(
                                title,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
                            );
                          },
                        ).toList(),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: colorScheme
                                .surfaceVariant, // A slightly different background for the "Other" button
                            borderRadius: BorderRadius.circular(
                              AppRadius.md,
                            ), // Using AppRadius
                          ),
                          child: Icon(
                            Icons.more_horiz,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
