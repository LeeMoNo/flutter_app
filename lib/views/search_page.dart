import 'package:flutter/material.dart';
import '../services/dict_service.dart';

enum _SearchMode { idle, browse, keyword }

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static const _jlptOptions = ['N5', 'N4', 'N3', 'N2', 'N1'];
  static const _posOptions = ['名词', '动词', '形容词', '副词', '助词'];

  final _svc = DictService();
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<DictEntry> _results = [];
  _SearchMode _mode = _SearchMode.idle;
  String? _selectedJlpt;
  String? _selectedPos;
  int _page = 1;
  int _total = 0;
  bool _hasMore = false;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;

  bool get _hasActiveFilter => _selectedJlpt != null || _selectedPos != null;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_mode != _SearchMode.browse || !_hasMore || _loadingMore || _loading) {
      return;
    }
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _loadEntries(reset: false);
    }
  }

  void _resetToIdle() {
    setState(() {
      _mode = _SearchMode.idle;
      _results = [];
      _page = 1;
      _total = 0;
      _hasMore = false;
      _loading = false;
      _loadingMore = false;
      _error = null;
    });
  }

  Future<void> _loadEntries({required bool reset}) async {
    if (!_hasActiveFilter) {
      _resetToIdle();
      return;
    }

    if (_selectedPos != null && _selectedJlpt == null) {
      setState(() {
        _mode = _SearchMode.browse;
        _results = [];
        _error = null;
        _loading = false;
        _loadingMore = false;
      });
      return;
    }

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _results = [];
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final result = await _svc.getEntries(
        jlpt: _selectedJlpt,
        pos: _selectedPos,
        page: reset ? 1 : _page + 1,
        limit: 20,
      );
      if (!mounted) return;
      setState(() {
        _mode = _SearchMode.browse;
        _page = result.page;
        _total = result.total;
        _hasMore = result.hasMore;
        _results = reset ? result.results : [..._results, ...result.results];
        _loading = false;
        _loadingMore = false;
        _error = null;
      });
    } on DictServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = e.message;
        if (_results.isEmpty) _mode = _SearchMode.browse;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _error = '网络异常，请稍后重试';
      });
    }
  }

  Future<void> _search(String q) async {
    final query = q.trim();
    if (query.isEmpty) {
      _ctrl.clear();
      if (_hasActiveFilter) {
        _loadEntries(reset: true);
      } else {
        _resetToIdle();
      }
      return;
    }

    if (!JapaneseQueryValidator.isJapanese(query)) {
      setState(() {
        _mode = _SearchMode.idle;
        _results = [];
        _total = 0;
        _hasMore = false;
        _loading = false;
        _error = '请输入日文或读音，不支持其他语言搜索';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _results = [];
      _hasMore = false;
      _selectedJlpt = null;
      _selectedPos = null;
    });

    try {
      final results = await _svc.search(query);
      if (!mounted) return;
      setState(() {
        _mode = _SearchMode.keyword;
        _results = results;
        _total = results.length;
        _loading = false;
        _error = null;
      });
    } on DictServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = '网络异常，请稍后重试';
      });
    }
  }

  void _onJlptSelected(String? jlpt) {
    setState(() {
      _selectedJlpt = jlpt;
      _ctrl.clear();
    });
    if (jlpt == null && _selectedPos == null) {
      _resetToIdle();
      return;
    }
    if (_selectedPos != null && jlpt == null) {
      setState(() {
        _mode = _SearchMode.browse;
        _results = [];
        _error = null;
      });
      return;
    }
    _loadEntries(reset: true);
  }

  void _onPosSelected(String? pos) {
    setState(() {
      _selectedPos = pos;
      _ctrl.clear();
    });
    if (pos == null && _selectedJlpt == null) {
      _resetToIdle();
      return;
    }
    if (pos != null && _selectedJlpt == null) {
      setState(() {
        _mode = _SearchMode.browse;
        _results = [];
        _error = null;
      });
      return;
    }
    _loadEntries(reset: true);
  }

  void _clearFilters() {
    setState(() {
      _selectedJlpt = null;
      _selectedPos = null;
      _ctrl.clear();
    });
    _resetToIdle();
  }

  String _emptyMessage() {
    if (_mode == _SearchMode.keyword) return '未找到相关词条';
    if (_selectedPos != null && _selectedJlpt == null) {
      return '词性筛选需同时选择 JLPT 等级';
    }
    if (_mode == _SearchMode.idle) {
      return '输入关键词，或选择 JLPT / 词性 开始查询';
    }
    return '未找到符合条件的词条';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RedSun 词典'),
        actions: [
          if (_hasActiveFilter)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('清除筛选'),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _ctrl,
              decoration: InputDecoration(
                hintText: '日文 / 读音',
                border: const OutlineInputBorder(),
                suffixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _search(_ctrl.text),
                      ),
              ),
              onSubmitted: _search,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(height: 8),
          _FilterSection(
            jlptOptions: _jlptOptions,
            posOptions: _posOptions,
            selectedJlpt: _selectedJlpt,
            selectedPos: _selectedPos,
            enabled: !_loading,
            onJlptSelected: _onJlptSelected,
            onPosSelected: _onPosSelected,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          if (!_loading && _results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Text(
                _mode == _SearchMode.keyword
                    ? '搜索到 ${_results.length} 条结果'
                    : '共 $_total 条 · 第 $_page 页',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          Expanded(child: _buildResultList()),
        ],
      ),
    );
  }

  Widget _buildResultList() {
    if (_loading && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _emptyMessage(),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _results.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        if (index >= _results.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        return _DictEntryTile(entry: _results[index]);
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  final List<String> jlptOptions;
  final List<String> posOptions;
  final String? selectedJlpt;
  final String? selectedPos;
  final bool enabled;
  final ValueChanged<String?> onJlptSelected;
  final ValueChanged<String?> onPosSelected;

  const _FilterSection({
    required this.jlptOptions,
    required this.posOptions,
    required this.selectedJlpt,
    required this.selectedPos,
    required this.enabled,
    required this.onJlptSelected,
    required this.onPosSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('JLPT', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              _FilterChip(
                label: '全部',
                selected: selectedJlpt == null,
                enabled: enabled,
                onSelected: () => onJlptSelected(null),
              ),
              ...jlptOptions.map(
                (level) => _FilterChip(
                  label: level,
                  selected: selectedJlpt == level,
                  enabled: enabled,
                  onSelected: () => onJlptSelected(level),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('词性', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
          child: Row(
            children: [
              _FilterChip(
                label: '全部',
                selected: selectedPos == null,
                enabled: enabled,
                onSelected: () => onPosSelected(null),
              ),
              ...posOptions.map(
                (pos) => _FilterChip(
                  label: pos,
                  selected: selectedPos == pos,
                  enabled: enabled,
                  onSelected: () => onPosSelected(pos),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: enabled ? (_) => onSelected() : null,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 13,
          color: selected ? Theme.of(context).colorScheme.onPrimaryContainer : null,
        ),
      ),
    );
  }
}

class _DictEntryTile extends StatelessWidget {
  final DictEntry entry;

  const _DictEntryTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(
            entry.word,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            entry.reading,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const Spacer(),
          if (entry.jlpt != null)
            Chip(
              label: Text(entry.jlpt!),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              labelStyle: const TextStyle(fontSize: 12),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(entry.zhCn, style: const TextStyle(fontSize: 15)),
              ),
              if (entry.pos != null)
                Text(
                  entry.pos!,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
            ],
          ),
          if (entry.exampleJp != null) ...[
            const SizedBox(height: 4),
            Text(
              entry.exampleJp!,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
            if (entry.exampleZh != null)
              Text(
                entry.exampleZh!,
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ],
      ),
    );
  }
}
