import 'package:flutter/material.dart';
import 'package:flutter_application_1/views/detail_screen.dart';
import 'package:flutter_application_1/views/home_screen.dart';
import 'package:get/get.dart';
import 'views/water_reminder_page.dart';
import 'views/settings_page.dart';
import 'views/hydration_plan_page.dart';
import 'views/drink_history_page.dart';
import 'views/history_detail_page.dart';
import 'views/profile_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '设置喝水提醒项目',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const WaterReminderPage()),
        GetPage(name: '/settings', page: () => const SettingsPage()),
        GetPage(name: '/plan', page: () => const HydrationPlanPage()),
        GetPage(name: '/history', page: () => const DrinkHistoryPage()),
        GetPage(name: '/history-detail', page: () => const HistoryDetailPage()),
        GetPage(name: '/profile', page: () => const ProfilePage()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(
          name: '/detail',
          page: () => DetailScreen(articleId: Get.arguments['articleId']),
        ),
      ],
    );
  }
}
