import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DrinkHistoryPage extends StatelessWidget {
  const DrinkHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final records = List.generate(
      8,
      (index) => {
        'title': '第 ${index + 1} 次喝水',
        'time': '2026-03-23 ${8 + index}:00',
        'amount': '${100 + index * 10}ml',
      },
    );

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AppBar(
              title: const Text('喝水历史记录'),
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final item = records[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title'] ?? ''),
                subtitle: Text('${item['time']}  ·  ${item['amount']}'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => Get.toNamed(
                  '/history-detail',
                  arguments: {
                    'title': item['title'],
                    'time': item['time'],
                    'amount': item['amount'],
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
