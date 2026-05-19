import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/device_service.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final String articleId;
  const DetailScreen({super.key, required this.articleId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Article? _article;
  bool _loading = true;
  String? _error;
  // 新增状态变量
  int _viewCount = 0;
  int _likeCount = 0;
  int _dislikeCount = 0;
  String? _userReaction; // 'like' | 'dislike' | null
  String _deviceId = '';
  bool _reacting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // _deviceId = await DeviceService.getDeviceId();
    _deviceId = '1234567890';
    print('deviceId:=>$_deviceId');
    await _load(); // 加载文章
    await ApiService.recordView(widget.articleId); // 记录阅读
    await _loadReaction(); // 加载互动状态
  }

  Future<void> _loadReaction() async {
    try {
      final data = await ApiService.getReaction(widget.articleId, _deviceId);
      print('data:=>$data');
      setState(() {
        _viewCount = data['view_count'] ?? 0;
        _likeCount = data['like_count'] ?? 0;
        _dislikeCount = data['dislike_count'] ?? 0;
        _userReaction = data['user_reaction'];
      });
    } catch (_) {}
  }

  Future<void> _react(String reaction) async {
    if (_reacting) return;
    setState(() => _reacting = true);
    try {
      final data = await ApiService.react(
        widget.articleId,
        _deviceId,
        reaction,
      );
      setState(() {
        _likeCount = data['like_count'] ?? 0;
        _dislikeCount = data['dislike_count'] ?? 0;
        _userReaction = data['user_reaction'];
      });
    } finally {
      setState(() => _reacting = false);
    }
  }

  Future<void> _load() async {
    try {
      final a = await ApiService.getArticle(widget.articleId);
      setState(() {
        _article = a;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.white, body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            TextButton(onPressed: _load, child: const Text('重试')),
          ],
        ),
      );
    }

    final article = _article!;
    final time = article.publishedAt ?? article.createdAt;

    return CustomScrollView(
      slivers: [
        // 顶部封面 + 返回按钮
        SliverAppBar(
          expandedHeight: article.coverUrl != null ? 240 : 0,
          pinned: true,
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF111827),
          elevation: 0,
          flexibleSpace:
              article.coverUrl != null
                  ? FlexibleSpaceBar(
                    background: CachedNetworkImage(
                      imageUrl: article.coverUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                  : null,
        ),

        // 正文
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 类型标签
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    article.type == 'video' ? '🎬 视频' : '📄 文章',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 标题
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // 时间
                Text(
                  timeago.format(time, locale: 'zh'),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 28),

                // 分割线
                Container(height: 1, color: const Color(0xFFF3F4F6)),
                const SizedBox(height: 28),

                // 富文本内容 ← 核心
                HtmlWidget(
                  article.content,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    height: 1.75,
                    color: Color(0xFF1F2937),
                  ),
                  customStylesBuilder: (element) {
                    // 统一各元素样式
                    switch (element.localName) {
                      case 'h1':
                        return {
                          'font-size': '22px',
                          'font-weight': '700',
                          'margin': '20px 0 10px',
                        };
                      case 'h2':
                        return {
                          'font-size': '19px',
                          'font-weight': '700',
                          'margin': '18px 0 8px',
                        };
                      case 'h3':
                        return {
                          'font-size': '16px',
                          'font-weight': '600',
                          'margin': '14px 0 6px',
                        };
                      case 'blockquote':
                        return {
                          'border-left': '3px solid #e5e7eb',
                          'padding-left': '16px',
                          'color': '#6b7280',
                        };
                      case 'img':
                        return {
                          'max-width': '100%',
                          'border-radius': '8px',
                          'margin': '12px 0',
                        };
                      case 'pre':
                        return {
                          'background': '#1e1e2e',
                          'color': '#cdd6f4',
                          'padding': '16px',
                          'border-radius': '8px',
                        };
                      case 'a':
                        return {'color': '#4f46e5'};
                    }
                    return null;
                  },
                  onTapUrl: (url) async {
                    // 处理链接点击（可集成 url_launcher）
                    debugPrint('点击链接: $url');
                    return true;
                  },
                ),
                const SizedBox(height: 40),

                // ─── 互动栏 ───────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(5),
                  // decoration: BoxDecoration(
                  //   color: const Color(0xFFF9FAFB),
                  //   borderRadius: BorderRadius.circular(16),
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 阅读量
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            size: 16,
                            color: Color(0xFF9CA3AF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_viewCount 次阅读',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),

                      // 点赞 / 踩
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 点赞按钮
                          _ReactionButton(
                            icon: Icons.thumb_up_outlined,
                            activeIcon: Icons.thumb_up,
                            label: '$_likeCount',
                            isActive: _userReaction == 'like',
                            activeColor: const Color(0xFF4F46E5),
                            onTap: () => _react('like'),
                          ),
                          const SizedBox(width: 15),
                          // 踩按钮
                          _ReactionButton(
                            icon: Icons.thumb_down_outlined,
                            activeIcon: Icons.thumb_down,
                            label: '$_dislikeCount',
                            isActive: _userReaction == 'dislike',
                            activeColor: const Color(0xFFDC2626),
                            onTap: () => _react('dislike'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReactionButton extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _ReactionButton({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        // decoration: BoxDecoration(
        //   color: isActive ? activeColor.withOpacity(0.08) : Colors.white,
        //   borderRadius: BorderRadius.circular(50),
        //   border: Border.all(
        //     color: isActive ? activeColor : const Color(0xFFE5E7EB),
        //     width: isActive ? 1.1 : 1,
        //   ),
        // ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 19,
            color: isActive ? activeColor : const Color(0xFF6B7280),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isActive ? activeColor : const Color(0xFF6B7280),
            ),
          ),
        ]),
      ),
    );
  }
}
