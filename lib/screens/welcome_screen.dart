import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              const Text(
                'Lietuvos',
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  height: 1.1,
                ),
              ),
              const Text(
                'Herbai',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '447 miest\u0173, miestelio ir seni\u016bnij\u0173 simboliai',
                style: TextStyle(fontSize: 14, color: Colors.white38),
              ),
              const Spacer(flex: 3),
              _FilterButton(
                label: 'Miestai ir rajonai',
                subtitle: 'Savivaldybi\u0173 centrai',
                icon: Icons.location_city_rounded,
                color: const Color(0xFF2196F3),
                onTap: () => _go(context, 'Miestai'),
              ),
              const SizedBox(height: 14),
              _FilterButton(
                label: 'Seni\u016bnijos',
                subtitle: 'Vietovi\u0173 ir miestelio herbai',
                icon: Icons.park_rounded,
                color: const Color(0xFF4CAF50),
                onTap: () => _go(context, 'Seniunija'),
              ),
              const SizedBox(height: 14),
              _FilterButton(
                label: 'Visi herbai',
                subtitle: 'Visas 447 herb\u0173 s\u0105ra\u0161as',
                icon: Icons.grid_view_rounded,
                color: const Color(0xFFFF9800),
                onTap: () => _go(context, 'Visi'),
              ),
              const SizedBox(height: 14),
              _FilterButton(
                label: 'Miest\u0173 \u017eaidimas',
                subtitle: 'Atspek kuri\u0173 miesto herbas \u2014 55 miest\u0173',
                icon: Icons.quiz_rounded,
                color: const Color(0xFFE040FB),
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, anim, __) => const GameScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                          parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                    transitionDuration: const Duration(milliseconds: 320),
                  ),
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, String filter) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) =>
            HomeScreen(initialFilter: filter),
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
              parent: anim, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: color.withValues(alpha: 0.35), width: 1.5),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white38)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 16, color: color.withValues(alpha: 0.7)),
            ],
          ),
        ),
      ),
    );
  }
}
