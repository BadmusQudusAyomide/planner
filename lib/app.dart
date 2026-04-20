import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';
import 'screens/planner_screen.dart';
import 'screens/birthdays_screen.dart';

const _bg = Color(0xFF0D0703);
const _navBg = Color(0xFF100804);
const _borderDim = Color(0xFF3D2410);
const _gold = Color(0xFFD4A017);
const _textDim = Color(0xFF4A2E14);

class PlannerApp extends StatelessWidget {
  const PlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Ria's Planner",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg,
        colorScheme: const ColorScheme.dark(
          primary: _gold,
          onPrimary: _bg,
          surface: Color(0xFF1A0E06),
          onSurface: Color(0xFFC9A47E),
        ),
        textTheme: GoogleFonts.dmSansTextTheme().apply(
          bodyColor: const Color(0xFFC9A47E),
          displayColor: const Color(0xFFC9A47E),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    PlannerScreen(),
    BirthdaysScreen(),
  ];

  static const _items = [
    _NavItem(label: 'Home', icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(label: 'Planner', icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month),
    _NavItem(label: 'Birthdays', icon: Icons.cake_outlined, activeIcon: Icons.cake),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      extendBody: true, // lets screen content go behind the floating bar
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildFloatingBar(),
    );
  }

  Widget _buildFloatingBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _navBg,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: _borderDim, width: 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            _items.length,
                (i) => _buildNavItem(i),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final selected = _currentIndex == index;
    final item = _items[index];

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2A1208) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _borderDim : Colors.transparent,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? item.activeIcon : item.icon,
              size: 18,
              color: selected ? _gold : _textDim,
            ),
            // label slides in/out with AnimatedSize
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: selected
                  ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  item.label.toUpperCase(),
                  style: GoogleFonts.dmSans(
                    fontSize: 10,
                    letterSpacing: 1.2,
                    color: _gold,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}