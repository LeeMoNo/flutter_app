import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryDetailPage extends StatelessWidget {
  const HistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (Get.arguments as Map?) ?? {};
    final title = args['title']?.toString() ?? '未知记录';
    final time = args['time']?.toString() ?? '--';
    final amount = args['amount']?.toString() ?? '--';

    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: AppBar(
              title: const Text('记录详情'),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 18),
              _infoRow('喝水时间', time),
              const SizedBox(height: 10),
              _infoRow('喝水量', amount),
              const SizedBox(height: 10),
              _infoRow('状态', '已完成'),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Get.toNamed('/profile'),
                  icon: const Icon(Icons.person),
                  label: const Text('查看我的饮水画像'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(width: 90, child: Text('$label:')),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
