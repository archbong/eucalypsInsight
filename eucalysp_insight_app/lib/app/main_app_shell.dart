// lib/app/main_app_shell.dart
import 'package:eucalysp_insight_app/app/core/bloc/navigation_cubit/navigation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb and TargetPlatform
import 'package:go_router/go_router.dart';
import 'package:eucalysp_insight_app/app/core/services/layout_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import flutter_bloc

class MainAppShell extends StatefulWidget {
  final Widget child;

  const MainAppShell({required this.child, super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  // Remove _selectedIndex from here, it will be managed by the Cubit
  // late int _selectedIndex; // THIS LINE SHOULD BE DELETED OR COMMENTED OUT

  // Helper to determine the current index based on the GoRouter's current location
  // This method will now *emit* the index to the Cubit instead of directly setting a state variable.
  void _updateNavigationIndexFromRoute(BuildContext context) {
    // Corrected to use .routerDelegate.currentConfiguration.uri.path for broader compatibility
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.uri.path;
    int newIndex;

    if (location.startsWith('/dashboard')) {
      newIndex = 0;
    } else if (location.startsWith('/inventory')) {
      newIndex = 1;
    } else if (location.startsWith('/sales')) {
      newIndex = 2;
    } else {
      newIndex = 0; // Default or fallback
    }

    // Get the Cubit and update its state
    context.read<NavigationCubit>().updateIndex(newIndex);
  }

  @override
  void initState() {
    super.initState();
    // No direct _selectedIndex initialization here.
    // We'll update the Cubit in a post-frame callback to ensure context is ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNavigationIndexFromRoute(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This is the ideal place to react to route changes.
    _updateNavigationIndexFromRoute(context);
  }

  // Corrected _onItemTapped signature to accept BuildContext
  void _onItemTapped(int index, BuildContext context) {
    // Update the Cubit's state
    context.read<NavigationCubit>().updateIndex(index);

    // Navigate using go_router
    final routes = ['/dashboard', '/inventory', '/sales'];
    if (index >= 0 && index < routes.length) {
      context.go(routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useMobileLayout = LayoutService.isMobileLayout(context);

    // Provide the NavigationCubit here and listen to its state
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, selectedIndex) {
          // selectedIndex now comes from the Cubit
          if (useMobileLayout) {
            // --- Mobile Layout ---
            return Scaffold(
              appBar: AppBar(
                title: const Text('EncalyspInsight (Mobile)'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: widget.child,
              bottomNavigationBar: BottomNavigationBar(
                items: const <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory),
                    label: 'Inventory',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart),
                    label: 'Sales',
                  ),
                ],
                currentIndex: selectedIndex, // Use the state from the Cubit
                onTap: (index) => _onItemTapped(index, context), // Pass context
              ),
            );
          } else {
            // --- Desktop/Web Layout ---
            return Scaffold(
              appBar: AppBar(
                title: const Text('EncalyspInsight (Desktop/Web)'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              body: Row(
                children: <Widget>[
                  NavigationRail(
                    selectedIndex:
                        selectedIndex, // Use the state from the Cubit
                    onDestinationSelected: (index) =>
                        _onItemTapped(index, context), // Pass context
                    labelType: NavigationRailLabelType.all,
                    destinations: const <NavigationRailDestination>[
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.inventory),
                        label: Text('Inventory'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.shopping_cart),
                        label: Text('Sales'),
                      ),
                    ],
                  ),
                  Expanded(child: widget.child),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
