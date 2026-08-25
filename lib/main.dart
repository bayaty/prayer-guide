import 'package:flutter/material.dart';
import 'data/app_settings.dart';
import 'theme/app_colors.dart';
import 'data/prayer_data.dart';
import 'screens/wudu_screen.dart';
import 'screens/prayer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read saved preferences before the first frame so the app opens with the
  // user's saved practice mode already applied.
  await AppSettings.instance.load();
  runApp(const SalahGuideApp());
}

class SalahGuideApp extends StatelessWidget {
  const SalahGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prayer Guide',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.scaffold,
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late final List<Widget> _screens = [
    const WuduScreen(),
    PrayerScreen(prayer: prayers[0]),
    PrayerScreen(prayer: prayers[1]),
    PrayerScreen(prayer: prayers[2]),
    PrayerScreen(prayer: prayers[3]),
    PrayerScreen(prayer: prayers[4]),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: AppColors.accent.withAlpha(30),
        height: 70,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.water_drop_outlined),
            selectedIcon: Icon(Icons.water_drop, color: AppColors.primary),
            label: 'Wudu',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_twilight_outlined),
            selectedIcon: Icon(Icons.wb_twilight, color: AppColors.primary),
            label: 'Fajr',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny, color: AppColors.primary),
            label: 'Dhuhr',
          ),
          NavigationDestination(
            icon: Icon(Icons.sunny_snowing),
            selectedIcon: Icon(Icons.sunny_snowing, color: AppColors.primary),
            label: 'Asr',
          ),
          NavigationDestination(
            icon: Icon(Icons.wb_twighlight),
            selectedIcon: Icon(Icons.wb_twighlight, color: AppColors.primary),
            label: 'Maghrib',
          ),
          NavigationDestination(
            icon: Icon(Icons.nightlight_outlined),
            selectedIcon: Icon(Icons.nightlight, color: AppColors.primary),
            label: 'Isha',
          ),
        ],
      ),
    );
  }
}
