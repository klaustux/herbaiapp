import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/herbas.dart';
import '../widgets/herbas_image.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  // Miestai + Rajonai + Savivaldybes = 60 vnt. (po dedup: 55)
  static const _gameTypes = {'Miestas', 'Rajonas', 'Savivaldyb\u0117'};

  List<Herbas> _pool = [];
  bool _loading = true;

  late Herbas _left;
  late Herbas _right;
  late Herbas _answer;   // kurio miesto pavadinimas rodomas

  int _correct = 0;
  int _errors = 0;
  bool _gameOver = false;

  // Feedback state
  bool _showWrongLeft = false;
  bool _showWrongRight = false;
  bool _answering = false;   // blokuoja paspaudima animacijos metu

  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  final _rng = Random();

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticOut),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    final raw = await rootBundle.loadString('assets/json/herbai.json');
    final all = (jsonDecode(raw) as List)
        .map((j) => Herbas.fromJson(j as Map<String, dynamic>))
        .where((h) => _gameTypes.contains(h.type))
        .toList();

    // Deduplikuoti pagal miesto pavadinima:
    // jei yra ir miesto, ir rajono herbas – palikti tik miesto
    final typePriority = {'Miestas': 0, 'Savivaldybė': 1, 'Rajonas': 2};
    final Map<String, Herbas> unique = {};
    for (final h in all) {
      final existing = unique[h.name];
      if (existing == null) {
        unique[h.name] = h;
      } else {
        final newPrio  = typePriority[h.type]        ?? 99;
        final prevPrio = typePriority[existing.type] ?? 99;
        if (newPrio < prevPrio) unique[h.name] = h;
      }
    }

    setState(() {
      _pool = unique.values.toList();
      _loading = false;
    });
    _nextRound();
  }

  void _nextRound() {
    // Pasirinkti 2 skirtingus heralds
    final copy = List<Herbas>.from(_pool)..shuffle(_rng);
    _left = copy[0];
    _right = copy[1];
    // Atsakymas – atsitiktinai vienas is ju
    _answer = _rng.nextBool() ? _left : _right;
    _showWrongLeft = false;
    _showWrongRight = false;
    _answering = false;
    setState(() {});
  }

  Future<void> _onTap(Herbas tapped) async {
    if (_answering || _gameOver) return;
    _answering = true;

    if (tapped.id == _answer.id) {
      // Teisingas atsakymas
      setState(() => _correct++);
      await Future.delayed(const Duration(milliseconds: 180));
      setState(() => _nextRound());
    } else {
      // Neteisingas
      setState(() {
        _errors++;
        _showWrongLeft  = (tapped.id == _left.id);
        _showWrongRight = (tapped.id == _right.id);
      });
      _shakeCtrl.forward(from: 0);
      await Future.delayed(const Duration(milliseconds: 900));
      if (_errors >= 3) {
        setState(() => _gameOver = true);
      } else {
        setState(() {
          _showWrongLeft  = false;
          _showWrongRight = false;
          _answering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F2027),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    if (_gameOver) return _buildGameOver(context);
    return _buildGame(context);
  }

  Widget _buildGame(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        color: Colors.white54, size: 20),
                  ),
                  const SizedBox(width: 8),
                  const Text('Miesto \u017eaidimas',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const Spacer(),
                  // Klaidu skaitliukas (sirdeles)
                  Row(
                    children: List.generate(3, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          i < (3 - _errors)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: i < (3 - _errors)
                              ? const Color(0xFFEF5350)
                              : Colors.white24,
                          size: 22,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(width: 12),
                  // Teisingi atsakymai
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                    ),
                    child: Text('$_correct',
                        style: const TextStyle(
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── Du herbai ────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _HerbCard(
                      herbas: _left,
                      showWrong: _showWrongLeft,
                      onTap: () => _onTap(_left),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HerbCard(
                      herbas: _right,
                      showWrong: _showWrongRight,
                      onTap: () => _onTap(_right),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // ── Miesto pavadinimas ───────────────────────────
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (_, child) {
                final shake = sin(_shakeAnim.value * pi * 6) * 8;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: child,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  _answer.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOver(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ikona
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF5350).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFEF5350).withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.sentiment_dissatisfied_rounded,
                      size: 44, color: Color(0xFFEF5350)),
                ),
                const SizedBox(height: 28),
                const Text(
                  '\u017daidimas baigtas',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 12),
                Text(
                  '$_correct',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 72,
                      fontWeight: FontWeight.w800,
                      height: 1.0),
                ),
                const Text(
                  'ATSPĖTŲ HERBŲ',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2),
                ),
                const SizedBox(height: 40),
                // Zaisti is naujo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _correct = 0;
                        _errors = 0;
                        _gameOver = false;
                      });
                      _nextRound();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Žaisti iš naujo',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.home_rounded,
                        color: Colors.white70, size: 20),
                    label: const Text('Pagrindinis langas',
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(
                          color: Colors.white24, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    super.dispose();
  }
}

// ── Herbo kortelis ───────────────────────────────────────────────────────────
class _HerbCard extends StatefulWidget {
  final Herbas herbas;
  final bool showWrong;
  final VoidCallback onTap;

  const _HerbCard({
    required this.herbas,
    required this.showWrong,
    required this.onTap,
  });

  @override
  State<_HerbCard> createState() => _HerbCardState();
}

class _HerbCardState extends State<_HerbCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1.0, end: 0.93).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 180,
          decoration: BoxDecoration(
            color: widget.showWrong
                ? const Color(0xFFEF5350).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.showWrong
                  ? const Color(0xFFEF5350).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.1),
              width: widget.showWrong ? 2 : 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: HerbasImage(
                  herbas: widget.herbas,
                  fit: BoxFit.contain,
                ),
              ),
              if (widget.showWrong)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(Icons.close_rounded,
                        size: 64, color: Color(0xFFEF5350)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
