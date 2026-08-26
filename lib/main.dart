import 'package:flutter/material.dart';
import 'data/active_prayer.dart';
import 'data/azan_times.dart';
import 'data/app_settings.dart';
import 'theme/app_colors.dart';
import 'data/prayer_data.dart';
import 'screens/wudu_screen.dart';
import 'widgets/now_badge.dart';
import 'screens/prayer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read saved preferences before the first frame so the app opens with the
  // user's saved practice mode already applied.
  await AppSettings.instance.load();
  await AzanTimes.instance.load();
  ActivePrayer.instance.start();
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


  /// A navigation tab labelled with the prayer's time for today, marked with
  /// a star while that prayer's time is in.
  NavigationDestination _prayerTab(
    IconData icon,
    IconData selectedIcon,
    String name,
  ) {
    final minutes = AzanTimes.instance.today?.forPrayer(name);
    final isNow = ActivePrayer.instance.isNow(name);

    // The label carries the time, so the bar doubles as a timetable.
    final label = minutes == null
        ? name
        : '$name  ${AzanTimes.format(minutes)}';

    // A star sits on the icon of whichever prayer is in.
    Widget mark(Widget child) {
      if (!isNow) return child;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          const Positioned(
            top: -5,
            right: -8,
            child: NowBadge(compact: true),
          ),
        ],
      );
    }

    return NavigationDestination(
      icon: mark(Icon(icon)),
      selectedIcon: mark(Icon(selectedIcon, color: AppColors.primary)),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      // The bar rebuilds every minute so the times and the marker stay
      // current without the user reopening the app.
      bottomNavigationBar: AnimatedBuilder(
        animation: ActivePrayer.instance,
        builder: (context, _) => NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          backgroundColor: Colors.white,
          indicatorColor: AppColors.accent.withAlpha(30),
          height: 74,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.water_drop_outlined),
              selectedIcon: Icon(Icons.water_drop, color: AppColors.primary),
              label: 'Wudu',
            ),
            _prayerTab(Icons.wb_twilight_outlined, Icons.wb_twilight, 'Fajr'),
            _prayerTab(Icons.wb_sunny_outlined, Icons.wb_sunny, 'Dhuhr'),
            _prayerTab(Icons.sunny_snowing, Icons.sunny_snowing, 'Asr'),
            _prayerTab(Icons.wb_twighlight, Icons.wb_twighlight, 'Maghrib'),
            _prayerTab(Icons.nightlight_outlined, Icons.nightlight, 'Isha'),
          ],
        ),
      ),
    );
  }
}
