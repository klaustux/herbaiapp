import 'package:flutter/material.dart';
import '../models/herbas.dart';
import '../widgets/herbas_image.dart';

class DetailScreen extends StatelessWidget {
  final Herbas herbas;

  const DetailScreen({super.key, required this.herbas});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(herbas.type);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          herbas.name,
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero image section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: Center(
                child: HerbasImage(
                  herbas: herbas,
                  height: 240,
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _InfoRow(
                        icon: Icons.location_city,
                        label: 'Pavadinimas',
                        value: herbas.name,
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.category_outlined,
                        label: 'Tipas',
                        value: herbas.type,
                        valueWidget: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: typeColor.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            herbas.type,
                            style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.map_outlined,
                        label: 'Apskritis',
                        value: herbas.county.replaceAll(' apskritis', ''),
                      ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.shield_outlined,
                        label: 'Herbas',
                        value: herbas.herbasName,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Miestas':
        return const Color(0xFF2196F3);
      case 'Rajonas':
        return const Color(0xFFF57C00);
      case 'Savivaldybė':
        return const Color(0xFF9C27B0);
      case 'Seniūnija':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFF757575);
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? valueWidget;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              valueWidget ??
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1A1A2E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
