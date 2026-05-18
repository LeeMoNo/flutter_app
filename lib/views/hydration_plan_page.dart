import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HydrationPlanPage extends StatelessWidget {
  const HydrationPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> plan = [
      {'time': '08:30', 'amount': '200ml'},
      {'time': '11:00', 'amount': '150ml'},
      {'time': '14:30', 'amount': '200ml'},
      {'time': '17:00', 'amount': '150ml'},
      {'time': '20:00', 'amount': '100ml'},
    ];

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AppBar(
              title: const Text('今日喝水计划'),
            ),
          ),
        ),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final item = plan[index];
            return ListTile(
              tileColor: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              leading: const Icon(Icons.schedule),
              title: Text('${item['time']} 喝水'),
              subtitle: Text('建议饮水量 ${item['amount']}'),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemCount: plan.length,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed('/history'),
          icon: const Icon(Icons.history),
          label: const Text('去看记录'),
        ),
      ),
    );
  }
}
