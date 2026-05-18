import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../viewmodels/water_reminder_viewmodel.dart';

class WaterReminderPage extends StatelessWidget {
  const WaterReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterReminderViewModel(),
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 30),
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: AppBar(
                title: const Text('喝水提醒'),
                actions: [
                  IconButton(
                    onPressed: () => Get.toNamed('/settings'),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ),
          body: const _WaterReminderContent(),
        ),
      ),
    );
  }
}

class _WaterReminderContent extends StatefulWidget {
  static const double imageHeight = 500;

  const _WaterReminderContent();

  @override
  State<_WaterReminderContent> createState() => _WaterReminderContentState();
}

class _WaterReminderContentState extends State<_WaterReminderContent> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupReminderListener(context);
    });
  }

  void _setupReminderListener(BuildContext context) {
    final viewModel = context.read<WaterReminderViewModel>();
    viewModel.addListener(() {
      Get.back();//先关闭已有的弹窗
      _showReminderDialog(context, viewModel);
    });
  }

  // 显示喝水提醒弹窗
  void _showReminderDialog(BuildContext context, WaterReminderViewModel viewModel) {
    // 如果已经达到每日目标，则不再显示弹窗
    if (viewModel.consumedAmount >= viewModel.dailyGoal) {
      return;
    }

    //dialog重复创建会叠加，怎么让dialog每次创建的时候
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.orange,
        title: const Text('喝水提醒'),
        content: const Text('朋友你该喝水了，此次要喝100毫升哦！'),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.cancelReminder();
              Navigator.pop(context);
            },
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.recordDrink();
              //
              Navigator.pop(context);
              //get库关闭弹窗，
              Get.back();
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WaterReminderViewModel>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 500,
              height: _WaterReminderContent.imageHeight,
              child: Image.asset('assets/images/drink_water.png'),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '今日已喝水量: ${viewModel.consumedAmount}ml',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            '剩余目标: ${viewModel.dailyGoal - viewModel.consumedAmount}ml',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          _NavigationTestPanel(),
          const SizedBox(height: 20),
          const Text(
            '喝水记录:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          ...viewModel.drinkHistory.map((time) => Text(
            '喝水时间: ${time.toString()}',
            style: const TextStyle(fontSize: 14),
          )).toList(),
          const SizedBox(height: 20),
          //点击事件跳转到文章列表页
          TextButton(
            onPressed: () => Get.toNamed('/home'),
            child: const Text('文章列表'),
          ),
        ],
      ),
    );
  }
}

class _NavigationTestPanel extends StatelessWidget {
  final List<_NavItem> items = const [
    _NavItem(title: '喝水计划页', icon: Icons.calendar_today, route: '/plan'),
    _NavItem(title: '历史记录页', icon: Icons.history, route: '/history'),
    _NavItem(title: '记录详情页', icon: Icons.description, route: '/history-detail'),
    _NavItem(title: '个人画像页', icon: Icons.person, route: '/profile'),
    _NavItem(title: '设置页', icon: Icons.settings, route: '/settings'),
  ];

  _NavigationTestPanel();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '页面跳转测试:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => ActionChip(
                  avatar: Icon(item.icon, size: 18),
                  label: Text(item.title),
                  onPressed: () => Get.toNamed(item.route),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _NavItem {
  final String title;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.route,
  });
}
