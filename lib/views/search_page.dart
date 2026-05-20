import 'package:flutter/material.dart';
import '../services/dict_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _svc  = DictService();
  final _ctrl = TextEditingController();
  List<DictEntry> _results = [];
  bool _loading = false;

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) return;
    setState(() => _loading = true);
    final results = await _svc.search(q);
    setState(() { _results = results; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RedSun 词典')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _ctrl,
            decoration: InputDecoration(
              hintText: '日文 / 读音 / 中文',
              border: const OutlineInputBorder(),
              suffixIcon: _loading
                ? const Padding(padding: EdgeInsets.all(12),
                    child: SizedBox(width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _search(_ctrl.text)),
            ),
            onSubmitted: _search,
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = _results[i];
              return ListTile(
                title: Row(children: [
                  Text(e.word,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(e.reading,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const Spacer(),
                  if (e.jlpt != null) Chip(
                    label: Text(e.jlpt!),
                    padding: EdgeInsets.zero,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                ]),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.zhCn, style: const TextStyle(fontSize: 15)),
                    if (e.exampleJp != null) ...[
                      const SizedBox(height: 4),
                      Text(e.exampleJp!,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Text(e.exampleZh ?? '',
                        style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ]
                  ],
                ),
              );
            },
          ),
        ),
      ]),
    );
  }
}