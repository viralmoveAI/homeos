import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';

class AnimatedGradientBackground extends ConsumerStatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({super.key, required this.child});

  @override
  ConsumerState<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends ConsumerState<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // Slow, premium drift
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(appThemeNavigatorProvider);
    final themeGradient = themeState.gradient;
    final size = MediaQuery.of(context).size;

    // Extract colors for the aura effect
    final color1 = themeGradient.colors[1];
    final color2 = themeGradient.colors[0];

    return Material(
      child: Stack(
        children: [
          // 1. Base Layer (Solid theme background)
          Container(color: color2),

          // 2. Animated Aura Blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return Stack(
                children: [
                  _Blob(
                    color: color1.withOpacity(0.5),
                    size: size.width * 1.4,
                    offset: Offset(
                      size.width * 0.5 +
                          math.sin(_controller.value * 2 * math.pi) * 120,
                      size.height * 0.3 +
                          math.cos(_controller.value * 2 * math.pi) * 180,
                    ),
                  ),
                  _Blob(
                    color: Colors.white.withOpacity(0.3),
                    size: size.width * 0.9,
                    offset: Offset(
                      size.width * 0.2 +
                          math.cos(_controller.value * 2 * math.pi + 1.5) * 140,
                      size.height * 0.6 +
                          math.sin(_controller.value * 2 * math.pi + 1.5) * 120,
                    ),
                  ),
                  _Blob(
                    color: color1.withOpacity(0.4),
                    size: size.width * 1.3,
                    offset: Offset(
                      size.width * 0.8 +
                          math.sin(_controller.value * 2 * math.pi + 3.0) * 160,
                      size.height * 0.8 +
                          math.cos(_controller.value * 2 * math.pi + 3.0) * 140,
                    ),
                  ),
                ],
              );
            },
          ),

          // 3. Heavy Blur Layer to create the smooth mesh effect
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                  ),
                ),
              ),
            ),
          ),

          // 4. Content
          widget.child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  final Offset offset;

  const _Blob({required this.color, required this.size, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset.dx - size / 2,
      top: offset.dy - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withOpacity(0.8)],
            stops: const [0.3, 1.0],
          ),
        ),
      ),
    );
  }
}
