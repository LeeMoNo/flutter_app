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
      : id        = j['id'],
        word      = j['word'],
        reading   = j['reading'],
        zhCn      = j['zh_cn'],
        pos       = j['pos'],
        jlpt      = j['jlpt'],
        frequency = j['frequency'],
        exampleJp = j['example_jp'],
        exampleZh = j['example_zh'],
        tone = j['tone'];
}

class DictService {
  static const _base = 'https://redsun-dict.wasai-test.workers.dev';

  Future<List<DictEntry>> search(String q) async {
    final res = await http.get(
      Uri.parse('$_base/search?q=${Uri.encodeComponent(q)}'),
    );
    final data = jsonDecode(res.body);
    return (data['results'] as List)
        .map((e) => DictEntry.fromJson(e))
        .toList();
  }
}