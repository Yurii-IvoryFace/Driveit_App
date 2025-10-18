import 'package:driveit_app/app/widgets/app_drawer.dart';
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
  final _homePageKey = GlobalKey<HomePageState>();
  final _vehicleListKey = GlobalKey<VehiclesListPageState>();
  final _reportsPageKey = GlobalKey<ReportsPageState>();

  int _currentIndex = 0;

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
        key: _homePageKey,
        onFuelSummary: (vehicle) =>
            _openReportsTab(ReportsTab.fuel, vehicleId: vehicle?.id),
        onOpenGarage: () => _onDestinationSelected(1),
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
    const fabOffset = 90.0;
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(onSelect: _handleDrawerSelection),
      extendBody: true,
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        clipBehavior: Clip.none,
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
          if (_currentIndex == 0)
            Positioned(
              right: 20,
              bottom: fabOffset,
              child: _QuickAddFab(onPressed: _openHomeQuickAdd),
            ),
        ],
      ),
      bottomNavigationBar: _FrostedNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openReportsTab(ReportsTab tab, {String? vehicleId}) {
    setState(() {
      _currentIndex = 2;
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

  Future<void> _openHomeQuickAdd() async {
    final homeState = _homePageKey.currentState;
    if (homeState == null) {
      return;
    }
    final handled = await homeState.showQuickAddSheet();
    if (!handled && mounted) {
      _onDestinationSelected(1);
    }
  }
}

class _NavigationItem {
  const _NavigationItem({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _QuickAddFab extends StatelessWidget {
  const _QuickAddFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'home-quick-add',
      child: SizedBox(
        width: 42,
        height: 42,
        child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.add, size: 22),
        ),
      ),
    );
  }
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
