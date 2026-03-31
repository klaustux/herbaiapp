import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/herbas.dart';
import '../widgets/herbas_image.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final String initialFilter;
  const HomeScreen({super.key, this.initialFilter = 'Visi'});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Herbas> _all = [];
  List<Herbas> _filtered = [];
  String _search = '';
  late String _activeType;
  bool _loading = true;

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  static const _types = ['Visi', 'Miestas', 'Rajonas', 'Savivaldybe', 'Seniunija'];
  static const _typeLabels = {
    'Visi': 'Visi',
    'Miestas': 'Miestas',
    'Rajonas': 'Rajonas',
    'Savivaldybe': 'Savivaldyb\u0117',
    'Seniunija': 'Seni\u016bnija',
  };

  @override
  void initState() {
    super.initState();
    _activeType = widget.initialFilter == 'Miestai' ? 'Visi' : widget.initialFilter;
    _loadData();
  }

  Future<void> _loadData() async {
    final raw = await rootBundle.loadString('assets/json/herbai.json');
    final list = (jsonDecode(raw) as List)
        .map((j) => Herbas.fromJson(j as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    setState(() { _all = list; _loading = false; });
    _applyFilter();
  }

  bool _matchesType(Herbas h) {
    if (_activeType == 'Visi') {
      if (widget.initialFilter == 'Miestai') {
        return h.type == 'Miestas' || h.type == 'Rajonas' || h.type == 'Savivaldyb\u0117';
      }
      return true;
    }
    final label = _typeLabels[_activeType] ?? _activeType;
    return h.type == label;
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    setState(() {
      _filtered = _all.where((h) {
        final matchType = _matchesType(h);
        final matchSearch = q.isEmpty ||
            h.name.toLowerCase().contains(q) ||
            h.county.toLowerCase().contains(q);
        return matchType && matchSearch;
      }).toList();
    });
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Miestas':        return const Color(0xFF2196F3);
      case 'Rajonas':        return const Color(0xFFF57C00);
      case 'Savivaldyb\u0117': return const Color(0xFF9C27B0);
      case 'Seni\u016bnija':   return const Color(0xFF4CAF50);
      default:               return const Color(0xFF757575);
    }
  }

  String get _screenTitle {
    switch (widget.initialFilter) {
      case 'Miestai':    return 'Miestai ir rajonai';
      case 'Seniunija':  return 'Seni\u016bnijos';
      default:           return 'Visi herbai';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios,
                            size: 20, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_screenTitle,
                            style: const TextStyle(fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1A2E))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Text('${_filtered.length} herb\u0173',
                        style: const TextStyle(fontSize: 13,
                            color: Color(0xFF9CA3AF))),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) { _search = v; _applyFilter(); },
                      style: const TextStyle(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'Ie\u0161koti pavadinimo ar apskrities...',
                        hintStyle: const TextStyle(
                            color: Color(0xFF9CA3AF), fontSize: 14),
                        prefixIcon: const Icon(Icons.search,
                            size: 20, color: Color(0xFF9CA3AF)),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear,
                                    size: 18, color: Color(0xFF9CA3AF)),
                                onPressed: () {
                                  _searchController.clear();
                                  _search = '';
                                  _applyFilter();
                                })
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.initialFilter == 'Visi')
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _types.map((key) {
                          final label = _typeLabels[key] ?? key;
                          final active = _activeType == key;
                          final color = key == 'Visi'
                              ? const Color(0xFF1A1A2E)
                              : _typeColor(label);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _activeType = key);
                                _applyFilter();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: active
                                      ? color
                                      : color.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: active
                                          ? color
                                          : color.withValues(alpha: 0.3),
                                      width: 1.2),
                                ),
                                child: Text(label,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: active
                                            ? Colors.white
                                            : color)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text('Nieko nerasta',
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[500])),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          itemCount: _filtered.length,
                          itemBuilder: (ctx, i) => _HerbasCard(
                            herbas: _filtered[i],
                            typeColor: _typeColor(_filtered[i].type),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

class _HerbasCard extends StatelessWidget {
  final Herbas herbas;
  final Color typeColor;
  const _HerbasCard({required this.herbas, required this.typeColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(
                  builder: (_) => DetailScreen(herbas: herbas))),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: HerbasImage(herbas: herbas,
                        width: 48, height: 48, fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(herbas.name,
                          style: const TextStyle(fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 3),
                      Text(
                          herbas.county.replaceAll(
                              ' apskritis', ' aps.'),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(herbas.type,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: typeColor)),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: Color(0xFFD1D5DB)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
