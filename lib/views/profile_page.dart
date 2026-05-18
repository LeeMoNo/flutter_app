import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AppBar(
              title: const Text('我的饮水画像'),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_drink),
                  title: const Text('今日完成率'),
                  subtitle: const Text('80%'),
                  trailing: Chip(
                    label: const Text('良好'),
                    backgroundColor: Colors.green.shade100,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.bolt),
                  title: const Text('最佳喝水时段'),
                  subtitle: const Text('上午 9:00 - 11:00'),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Get.offAllNamed('/'),
                  icon: const Icon(Icons.home),
                  label: const Text('返回首页'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
