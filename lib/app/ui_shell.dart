import 'package:driveit_app/app/widgets/app_drawer.dart';
import 'package:driveit_app/app/widgets/quick_add_menu.dart';
import 'package:driveit_app/features/home/presentation/home_page.dart';
import 'package:driveit_app/features/reports/presentation/reports_page.dart';
import 'package:driveit_app/features/settings/presentation/settings_page.dart';
import 'package:driveit_app/features/vehicles/presentation/vehicles_list_page.dart';
import 'package:driveit_app/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UiShell extends StatefulWidget {
  const UiShell({super.key});

  @override
  State<UiShell> createState() => _UiShellState();
}

class _UiShellState extends State<UiShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _vehicleListKey = GlobalKey<VehiclesListPageState>();
  final _reportsPageKey = GlobalKey<ReportsPageState>();

  int _currentIndex = 0;
  bool _isQuickAddOpen = false;

  late final List<_NavigationItem> _items;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _items = const [
      _NavigationItem(label: 'Home', icon: Icons.home_outlined),
      _NavigationItem(
        label: 'Vehicles',
        icon: Icons.directions_car_filled_outlined,
      ),
      _NavigationItem(label: 'Reports', icon: Icons.pie_chart_outline),
      _NavigationItem(label: 'Settings', icon: Icons.settings_outlined),
    ];

    _pages = [
      HomePage(
        onFuelSummary: (vehicle) =>
            _openReportsTab(ReportsTab.fuel, vehicleId: vehicle?.id),
      ),
      VehiclesListPage(key: _vehicleListKey),
      ReportsPage(key: _reportsPageKey),
      const SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentItem = _items[_currentIndex];
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelect: _handleDrawerSelection),
      extendBody: true,
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _ShellHeader(
                    title: currentItem.label,
                    onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey(_currentIndex),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _pages[_currentIndex],
                    ),
                  ),
                ),
              ),
            ],
          ),
          QuickAddMenu(
            visible: _currentIndex == 0 && _isQuickAddOpen,
            onDismiss: () => setState(() => _isQuickAddOpen = false),
            onAction: _handleQuickAddAction,
          ),
        ],
      ),
      floatingActionButton: _buildFabForCurrentTab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _FrostedNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  Widget? _buildFabForCurrentTab() {
    if (_currentIndex == 0) {
      return FloatingActionButton(
        onPressed: _toggleQuickAdd,
        child: AnimatedRotation(
          duration: const Duration(milliseconds: 200),
          turns: _isQuickAddOpen ? 0.125 : 0,
          child: Icon(_isQuickAddOpen ? Icons.close : Icons.add),
        ),
      );
    }
    return null;
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
      _isQuickAddOpen = false;
    });
  }

  void _openReportsTab(ReportsTab tab, {String? vehicleId}) {
    setState(() {
      _currentIndex = 2;
      _isQuickAddOpen = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tab == ReportsTab.fuel) {
        _reportsPageKey.currentState?.showFuelSummary(vehicleId: vehicleId);
      } else {
        _reportsPageKey.currentState?.switchToTab(tab);
      }
    });
  }

  void _handleDrawerSelection(int index) {
    if (index < _items.length) {
      _onDestinationSelected(index);
    }
  }

  void _toggleQuickAdd() {
    setState(() {
      _isQuickAddOpen = !_isQuickAddOpen;
    });
  }

  void _handleQuickAddAction(QuickAddAction action) {
    setState(() => _isQuickAddOpen = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('${action.label} action tapped (todo)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _ShellHeader extends StatelessWidget {
  const _ShellHeader({required this.title, required this.onMenuTap});

  final String title;
  final VoidCallback onMenuTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final formattedDate = DateFormat('MMMM d, yyyy').format(now);
    return Row(
      children: [
        InkWell(
          onTap: onMenuTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceSecondary,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.menu),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                formattedDate,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryVariant],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.sync_alt, size: 18, color: Colors.black),
              SizedBox(width: 6),
              Text(
                'Sync',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FrostedNavBar extends StatelessWidget {
  const _FrostedNavBar({
    required this.currentIndex,
    required this.items,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final List<_NavigationItem> items;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final maxWidth = mediaWidth > 460 ? 420.0 : mediaWidth;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: SizedBox(
              height: 56,
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onDestinationSelected,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedFontSize: 12,
                unselectedFontSize: 12,
                items: items
                    .map(
                      (item) => BottomNavigationBarItem(
                        icon: Icon(item.icon),
                        label: item.label,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
