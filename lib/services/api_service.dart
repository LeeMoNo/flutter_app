import 'package:dio/dio.dart';
import '../config.dart';
import '../models/article.dart';

class ApiService {
  static final _dio = Dio(
    BaseOptions(
      baseUrl: Config.apiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  // 获取文章列表（分页）
  static Future<List<Article>> getArticles({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/api/articles',
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = res.data as List;
      return list.map((e) => Article.fromJson(e)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // 获取文章详情
  static Future<Article> getArticle(String id) async {
    try {
      final res = await _dio.get('/api/articles/$id');
      return Article.fromJson(res.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  static String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) return '网络连接超时';
    if (e.response?.statusCode == 404) return '内容不存在';
    return '请求失败，请稍后重试';
  }

  // 记录阅读
  static Future<void> recordView(String id) async {
    try {
      print('recordView:=>$id');
      await _dio.post('/api/articles/$id/view');
    } catch (_) {} // 静默失败，不影响用户体验
  }

  // 获取互动状态
  static Future<Map<String, dynamic>> getReaction(
    String id,
    String deviceId,
  ) async {
    final res = await _dio.get(
      '/api/articles/$id/reaction',
      queryParameters: {'device_id': deviceId},
    );
    return res.data;
  }

  // 点赞/踩
  static Future<Map<String, dynamic>> react(
    String id,
    String deviceId,
    String reaction,
  ) async {
    final res = await _dio.post(
      '/api/articles/$id/react',
      data: {'device_id': deviceId, 'reaction': reaction},
    );
    return res.data;
  }

}
