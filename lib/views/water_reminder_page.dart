import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../viewmodels/water_reminder_viewmodel.dart';

class _AppColors {
  static const primary = Color(0xFF26A69A);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF9E9E9E);
  static const border = Color(0xFFE8E8E8);
  static const cardBackground = Colors.white;
  static const pageBackground = Color(0xFFFAFAFA);
}

class WaterReminderPage extends StatelessWidget {
  const WaterReminderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WaterReminderViewModel(),
      child: SafeArea(
        top: true,
        child: Scaffold(
          backgroundColor: _AppColors.pageBackground,
          body: const _WaterReminderContent(),
        ),
      ),
    );
  }
}

class _WaterReminderContent extends StatefulWidget {
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
      if (!viewModel.shouldShowReminder) return;
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      _showReminderDialog(context, viewModel);
      viewModel.clearReminderFlag();
    });
  }

  void _showReminderDialog(
    BuildContext context,
    WaterReminderViewModel viewModel,
  ) {
    if (viewModel.consumedAmount >= viewModel.dailyGoal) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.water_drop, color: _AppColors.primary),
            SizedBox(width: 8),
            Text('喝水提醒'),
          ],
        ),
        content: const Text('该补充水分啦，建议此次饮用 100 毫升。'),
        actions: [
          TextButton(
            onPressed: () {
              viewModel.cancelReminder();
              Navigator.pop(context);
            },
            child: const Text('稍后'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _AppColors.primary,
            ),
            onPressed: () {
              viewModel.recordDrink();
              Navigator.pop(context);
            },
            child: const Text('已喝水'),
          ),
        ],
      ),
    );
  }

  void _showCustomAmountDialog(
    BuildContext context,
    WaterReminderViewModel viewModel,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('自定义饮水量'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: '请输入毫升数',
            suffixText: 'ml',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _AppColors.primary,
            ),
            onPressed: () {
              final amount = int.tryParse(controller.text.trim());
              if (amount != null && amount > 0) {
                viewModel.recordDrinkWithAmount(amount);
              }
              Navigator.pop(context);
            },
            child: const Text('记录'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WaterReminderViewModel>();
    final records = viewModel.todayRecords;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppHeader(
            onSettingsTap: () => Get.toNamed('/settings'),
            onProfileTap: () => Get.toNamed('/profile'),
          ),
          const SizedBox(height: 16),
          _ProgressCard(viewModel: viewModel),
          const SizedBox(height: 24),
          _QuickRecordSection(
            amounts: viewModel.quickAmounts,
            onAmountTap: (amount) => viewModel.recordDrinkWithAmount(amount),
            onCustomTap: () => _showCustomAmountDialog(context, viewModel),
          ),
          const SizedBox(height: 24),
          const _SectionTitle(title: '功能概览'),
          const SizedBox(height: 12),
          const _FeatureGrid(),
          const SizedBox(height: 24),
          _SectionHeader(
            title: '今日记录',
            trailing: '共 ${records.length} 次记录',
          ),
          const SizedBox(height: 12),
          if (records.isEmpty)
            _EmptyRecordsCard()
          else
            ...records.map((record) => _TodayRecordTile(record: record)),
        ],
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final VoidCallback onSettingsTap;
  final VoidCallback onProfileTap;

  const _AppHeader({
    required this.onSettingsTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: _AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.water_drop, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        const Text(
          '喝水提醒',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _AppColors.primary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onSettingsTap,
          icon: const Icon(Icons.settings_outlined, color: _AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: _AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.person, color: _AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final WaterReminderViewModel viewModel;

  const _ProgressCard({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              color: const Color(0xFFE3F2FD),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  height: 140,
                  child: Image.asset('assets/images/drink_water.png'),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                const Text(
                  '今日已饮水量',
                  style: TextStyle(
                    fontSize: 13,
                    color: _AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${viewModel.consumedAmount} ml',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '目标进度 ${viewModel.progressPercent}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _AppColors.primary,
                      ),
                    ),
                    Text(
                      '剩余 ${viewModel.remainingAmount}ml',
                      style: const TextStyle(
                        fontSize: 13,
                        color: _AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: viewModel.progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFEEEEEE),
                    color: _AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickRecordSection extends StatelessWidget {
  final List<int> amounts;
  final ValueChanged<int> onAmountTap;
  final VoidCallback onCustomTap;

  const _QuickRecordSection({
    required this.amounts,
    required this.onAmountTap,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionHeader(
          title: '快速记录',
          trailing: '自定义 +',
          trailingColor: _AppColors.primary,
          onTrailingTap: onCustomTap,
        ),
        const SizedBox(height: 12),
        Row(
          children: amounts
              .map(
                (amount) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: amount == amounts.last ? 0 : 8,
                    ),
                    child: _QuickAmountCard(
                      amount: amount,
                      onTap: () => onAmountTap(amount),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _QuickAmountCard extends StatelessWidget {
  final int amount;
  final VoidCallback onTap;

  const _QuickAmountCard({required this.amount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                '$amount',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'ml',
                style: TextStyle(fontSize: 12, color: _AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const _items = [
    _FeatureItem(
      title: '饮水计划',
      subtitle: '制定每日目标',
      icon: Icons.calendar_today_outlined,
      iconColor: Color(0xFF42A5F5),
      iconBg: Color(0xFFE3F2FD),
      route: '/plan',
    ),
    _FeatureItem(
      title: '历史趋势',
      subtitle: '查看过往数据',
      icon: Icons.history,
      iconColor: Color(0xFFAB47BC),
      iconBg: Color(0xFFF3E5F5),
      route: '/history',
    ),
    _FeatureItem(
      title: '记录详情',
      subtitle: '管理每笔摄入',
      icon: Icons.assignment_outlined,
      iconColor: Color(0xFF66BB6A),
      iconBg: Color(0xFFE8F5E9),
      route: '/history-detail',
    ),
    _FeatureItem(
      title: '文章列表',
      subtitle: '健康饮水百科',
      icon: Icons.grid_view_rounded,
      iconColor: Color(0xFFFFA726),
      iconBg: Color(0xFFFFF3E0),
      route: '/home',
    ),
    _FeatureItem(
      title: '个人画像',
      subtitle: '身体素质分析',
      icon: Icons.person_outline,
      iconColor: Color(0xFF29B6F6),
      iconBg: Color(0xFFE1F5FE),
      route: '/profile',
    ),
    _FeatureItem(
      title: '搜索词条',
      subtitle: '健康饮水百科',
      icon: Icons.search,
      iconColor: Color(0xFF78909C),
      iconBg: Color(0xFFECEFF1),
      route: '/search',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: _items
          .map(
            (item) => _FeatureCard(
              item: item,
              onTap: () => Get.toNamed(item.route),
            ),
          )
          .toList(),
    );
  }
}

class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String route;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.route,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureItem item;
  final VoidCallback onTap;

  const _FeatureCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AppColors.cardBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: item.iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: item.iconColor, size: 18),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: _AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayRecordTile extends StatelessWidget {
  final DrinkRecord record;

  const _TodayRecordTile({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              WaterReminderViewModel.iconForType(record.type),
              color: _AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm').format(record.time),
                  style: const TextStyle(
                    fontSize: 12,
                    color: _AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '+${record.amountMl}ml',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecordsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: _AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.water_drop_outlined, color: _AppColors.textSecondary, size: 32),
          SizedBox(height: 8),
          Text(
            '今天还没有饮水记录',
            style: TextStyle(color: _AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: _AppColors.textPrimary,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final Color? trailingColor;
  final VoidCallback? onTrailingTap;

  const _SectionHeader({
    required this.title,
    this.trailing,
    this.trailingColor,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _AppColors.textPrimary,
          ),
        ),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: trailingColor ?? _AppColors.textSecondary,
              ),
            ),
          ),
      ],
    );
  }
}
