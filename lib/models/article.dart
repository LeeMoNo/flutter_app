class Article {
  final String id;
  final String title;
  final String content;
  final String? coverUrl;
  final String type; // 'article' | 'video'
  final String? videoUrl;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;

  Article({
    required this.id,
    required this.title,
    required this.content,
    this.coverUrl,
    required this.type,
    this.videoUrl,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
  });

  factory Article.fromJson(Map<String, dynamic> j) => Article(
    id: j['id'],
    title: j['title'] ?? '',
    content: j['content'] ?? '',
    coverUrl: j['cover_url'],
    type: j['type'] ?? 'article',
    videoUrl: j['video_url'],
    status: j['status'] ?? 'published',
    publishedAt:
        j['published_at'] != null ? DateTime.parse(j['published_at']) : null,
    createdAt: DateTime.parse(j['created_at']),
    viewCount: j['view_count'] ?? 0,
    likeCount: j['like_count'] ?? 0,
    dislikeCount: j['dislike_count'] ?? 0,
  );
}
