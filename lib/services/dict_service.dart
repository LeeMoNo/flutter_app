import 'dart:convert';
import 'package:http/http.dart' as http;

class DictEntry {
  final int id;
  final String word;
  final String reading;
  final String zhCn;
  final String? pos;
  final String? jlpt;
  final int? frequency;
  final String? exampleJp;
  final String? exampleZh;
  final String? tone;

  DictEntry.fromJson(Map<String, dynamic> j)
      : id = j['id'],
        word = j['word'],
        reading = j['reading'],
        zhCn = j['zh_cn'],
        pos = j['pos'],
        jlpt = j['jlpt'],
        frequency = j['frequency'],
        exampleJp = j['example_jp'],
        exampleZh = j['example_zh'],
        tone = j['tone'];
}

/// 服务端 pos 字段尚未填充时，用词条形态做本地词性匹配。
class PosMatcher {
  static const _ichidanChars = 'いきしちにひみりえげせてねへめれ';

  static bool matches(DictEntry entry, String pos) {
    if (entry.pos != null && entry.pos!.isNotEmpty) {
      return entry.pos == pos || entry.pos!.contains(pos);
    }

    final word = entry.word;
    final zh = entry.zhCn;

    switch (pos) {
      case '动词':
        return _isVerb(word) || zh.contains('动词');
      case '名词':
        return !_isVerb(word) &&
            !_isIAdjective(word) &&
            !_isAdverb(word) &&
            !_isParticle(word) &&
            (zh.contains('名词') || _looksLikeNoun(word));
      case '形容词':
        return _isIAdjective(word) ||
            _isNaAdjective(word) ||
            zh.contains('形容词') ||
            zh.contains('形容动词');
      case '副词':
        return _isAdverb(word) || zh.contains('副词');
      case '助词':
        return _isParticle(word) || zh.contains('助词');
      default:
        return false;
    }
  }

  static bool _isVerb(String word) {
    if (word.endsWith('する') || word == '来る' || word == 'くる') {
      return true;
    }
    if (RegExp(r'[うくぐすつぬぶむ]$').hasMatch(word)) {
      return true;
    }
    if (word.endsWith('る') && word.length >= 2) {
      return _ichidanChars.contains(word[word.length - 2]);
    }
    return false;
  }

  static bool _isIAdjective(String word) {
    if (word.length < 2 || !word.endsWith('い')) return false;
    if (word.endsWith('ない')) return false;
    const exceptions = {'い', 'こい', 'すい', 'かい'};
    if (exceptions.contains(word)) return false;
    return RegExp(r'[あかさたなはまやらわがざだばぱ]い$').hasMatch(word) ||
        word.endsWith('しい') ||
        word.endsWith('たい');
  }

  static bool _isNaAdjective(String word) {
    const naAdj = {'きれい', '嫌い', '静か', '有名', '便利', '丈夫', '嫌', '好き'};
    return naAdj.contains(word);
  }

  static bool _looksLikeNoun(String word) {
    return word.isNotEmpty && !_isVerb(word) && !_isIAdjective(word);
  }

  static bool _isAdverb(String word) {
    return word.endsWith('に') &&
        word.length >= 2 &&
        !_isVerb(word) &&
        word != 'に';
  }

  static bool _isParticle(String word) {
    const particles = {
      'は', 'が', 'を', 'に', 'で', 'と', 'から', 'まで', 'より', 'へ', 'の', 'も', 'か', 'ね', 'よ', 'わ', 'さ', 'ぞ', 'ぜ', 'な', 'や',
    };
    return particles.contains(word);
  }
}

class DictService {
  static const _base = 'https://redsun-dict.wasai-test.workers.dev';

  String? _posFilterCacheKey;
  List<DictEntry>? _posFilterCache;

  Future<List<DictEntry>> search(String q) async {
    final query = q.trim();
    if (!JapaneseQueryValidator.isJapanese(query)) {
      throw DictServiceException('请输入日文或读音进行搜索');
    }
    final res = await http.get(
      Uri.parse('$_base/search?q=${Uri.encodeComponent(query)}'),
    );
    if (res.statusCode != 200) {
      throw DictServiceException('搜索失败 (${res.statusCode})');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return (data['results'] as List)
        .map((e) => DictEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 分页获取词条列表，支持 JLPT 等级与词性筛选。
  /// 词性筛选优先走服务端；若服务端 pos 未入库则按 JLPT 拉取后在本地匹配。
  Future<DictEntriesResult> getEntries({
    String? jlpt,
    String? pos,
    int page = 1,
    int limit = 10,
  }) async {
    if (pos == null) {
      return _fetchEntries(jlpt: jlpt, pos: null, page: page, limit: limit);
    }

    final apiResult = await _fetchEntries(
      jlpt: jlpt,
      pos: pos,
      page: page,
      limit: limit,
    );
    if (apiResult.total > 0) {
      return apiResult;
    }

    if (jlpt == null) {
      throw DictServiceException('词性筛选需同时选择 JLPT 等级');
    }

    return _fetchEntriesWithClientPosFilter(
      jlpt: jlpt,
      pos: pos,
      page: page,
      limit: limit,
    );
  }

  Future<DictEntriesResult> _fetchEntries({
    String? jlpt,
    String? pos,
    required int page,
    required int limit,
  }) async {
    final params = {
      if (jlpt != null) 'jlpt': jlpt,
      if (pos != null) 'pos': pos,
      'page': '$page',
      'limit': '$limit',
    };
    final uri = Uri.parse('$_base/entries').replace(queryParameters: params);
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw DictServiceException('获取词条失败 (${res.statusCode})');
    }
    return DictEntriesResult.fromJson(
      jsonDecode(res.body) as Map<String, dynamic>,
    );
  }

  Future<DictEntriesResult> _fetchEntriesWithClientPosFilter({
    required String jlpt,
    required String pos,
    required int page,
    required int limit,
  }) async {
    final cacheKey = '$jlpt|$pos';
    if (_posFilterCacheKey != cacheKey || _posFilterCache == null) {
      final filtered = <DictEntry>[];
      var serverPage = 1;
      var serverPages = 1;

      while (serverPage <= serverPages) {
        final batch = await _fetchEntries(
          jlpt: jlpt,
          page: serverPage,
          limit: 100,
        );
        serverPages = batch.pages;
        filtered.addAll(
          batch.results.where((entry) => PosMatcher.matches(entry, pos)),
        );
        serverPage++;
      }

      _posFilterCacheKey = cacheKey;
      _posFilterCache = filtered;
    }

    final filtered = _posFilterCache!;
    final start = (page - 1) * limit;
    final pageResults = filtered.skip(start).take(limit).toList();
    final pages = filtered.isEmpty ? 0 : (filtered.length / limit).ceil();

    return DictEntriesResult(
      page: page,
      limit: limit,
      total: filtered.length,
      pages: pages,
      results: pageResults,
    );
  }

  void clearPosFilterCache() {
    _posFilterCacheKey = null;
    _posFilterCache = null;
  }
}

class DictEntriesResult {
  final int page;
  final int limit;
  final int total;
  final int pages;
  final List<DictEntry> results;

  DictEntriesResult({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
    required this.results,
  });

  DictEntriesResult.fromJson(Map<String, dynamic> j)
      : page = j['page'] as int,
        limit = j['limit'] as int,
        total = j['total'] as int,
        pages = j['pages'] as int,
        results = (j['results'] as List)
            .map((e) => DictEntry.fromJson(e as Map<String, dynamic>))
            .toList();

  bool get hasMore => pages > 0 && page < pages;
}

class DictServiceException implements Exception {
  final String message;
  const DictServiceException(this.message);

  @override
  String toString() => message;
}

/// 校验搜索词是否包含日文字符（平假名、片假名、汉字）。
class JapaneseQueryValidator {
  static final _japaneseChar = RegExp(
    r'[\u3040-\u309F' // 平假名
    r'\u30A0-\u30FF' // 片假名
    r'\u4E00-\u9FFF' // 汉字
    r'\u3400-\u4DBF' // 汉字扩展 A
    r'\uFF66-\uFF9F' // 半角片假名
    r'ー・々〆ヵヶ]',
  );

  static bool isJapanese(String input) {
    final query = input.trim();
    if (query.isEmpty) return false;
    return _japaneseChar.hasMatch(query);
  }
}
