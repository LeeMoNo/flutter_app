import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/article.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Article> _articles = [];
  final _scrollController = ScrollController();
  bool _loading = false;
  bool _hasMore = true;
  int _page = 1;
  String? _error;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('zh', timeago.ZhCnMessages());
    _load();
    _scrollController.addListener(() {
      // 距离底部 200px 时加载下一页
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _load();
      }
    });
  }

  Future<void> _load() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await ApiService.getArticles(page: _page);
      setState(() {
        _articles.addAll(data);
        _page++;
        _hasMore = data.length >= 20;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _articles.clear();
      _page = 1;
      _hasMore = true;
    });
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          '最新内容',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFF3F4F6)),
        ),
      ),
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_error != null && _articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            TextButton(onPressed: _refresh, child: const Text('重试')),
          ],
        ),
      );
    }

    if (_articles.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length + 1,
      itemBuilder: (context, i) {
        if (i == _articles.length) {
          if (_loading)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          if (!_hasMore)
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '没有更多了',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                ),
              ),
            );
          return const SizedBox.shrink();
        }
        return _ArticleCard(
          article: _articles[i],
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(articleId: _articles[i].id),
                ),
              ),
        );
      },
    );
  }
}

// ─── 文章卡片 ───────────────────────────────────────────────
class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isVideo = article.type == 'video';
    final time = article.publishedAt ?? article.createdAt;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 封面图
            if (article.coverUrl != null)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(14),
                ),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: article.coverUrl!,
                      width: double.infinity,
                      height: 180,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            height: 180,
                            color: const Color(0xFFF3F4F6),
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            height: 180,
                            color: const Color(0xFFF3F4F6),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFFD1D5DB),
                            ),
                          ),
                    ),
                    // 视频标识
                    if (isVideo)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // 内容
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 类型 badge
                  if (!isVideo) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isVideo ? '视频' : '文章',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4F46E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  // 标题
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 时间
                  Row(
                    children: [
                      Text(
                        timeago.format(time, locale: 'zh'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${article.viewCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.thumb_up_outlined,
                        size: 13,
                        color: Color(0xFF9CA3AF),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${article.likeCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
