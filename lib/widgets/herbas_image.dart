import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/herbas.dart';

class HerbasImage extends StatelessWidget {
  final Herbas herbas;
  final double? width;
  final double? height;
  final BoxFit fit;

  const HerbasImage({
    super.key,
    required this.herbas,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (herbas.isSvg) {
      return SvgPicture.asset(
        herbas.assetPath,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (_) => _placeholder(),
      );
    }

    return Image.asset(
      herbas.assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(
        width: width,
        height: height,
        child: const Center(
          child: Icon(Icons.shield_outlined, size: 32, color: Colors.grey),
        ),
      );
}
