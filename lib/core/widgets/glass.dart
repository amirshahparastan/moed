import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  const GlassBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: dark
                    ? const [Color(0xFF17233B), Color(0xFF0E1728)]
                    : const [Color(0xFFF9FCFF), Color(0xFFEAF3FF)],
              ),
            ),
          ),
        ),
        Positioned(
          top: -100,
          left: -80,
          child: _orb(260, AppColors.purple.withValues(alpha: dark ? .12 : .13)),
        ),
        Positioned(
          top: 110,
          right: -105,
          child: _orb(300, AppColors.cyan.withValues(alpha: dark ? .09 : .18)),
        ),
        Positioned(
          bottom: -130,
          left: 20,
          child: _orb(290, AppColors.blue.withValues(alpha: dark ? .08 : .12)),
        ),
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _orb(double size, Color color) => ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
      );
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final Color? foregroundColor;
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
    this.gradient,
    this.onTap,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradient ??
                LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: dark
                      ? [
                          Colors.white.withValues(alpha: .145),
                          Colors.white.withValues(alpha: .070),
                        ]
                      : [
                          Colors.white.withValues(alpha: .86),
                          const Color(0xFFF5FAFF).withValues(alpha: .58),
                        ],
                ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: dark
                  ? Colors.white.withValues(alpha: .13)
                  : Colors.white.withValues(alpha: .92),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5B72A5).withValues(alpha: dark ? .08 : .075),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: foregroundColor ??
                  (dark ? const Color(0xFFF5F7FF) : AppColors.ink),
            ),
            child: IconTheme.merge(
              data: IconThemeData(
                color: foregroundColor ??
                    (dark ? const Color(0xFFDDE6F7) : AppColors.ink),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: onTap,
      child: card,
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.blue, AppColors.cyan],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: .22),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: TextButton.icon(
            onPressed: onPressed,
            icon: icon == null
                ? const SizedBox.shrink()
                : Icon(icon, color: Colors.white),
            label: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
              ),
            ),
          ),
        ),
      );
}

class MoedLogo extends StatelessWidget {
  final double size;
  const MoedLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Transform.translate(
              offset: Offset(-size * .11, size * .02),
              child: Transform.rotate(
                angle: -.38,
                child: Container(
                  width: size * .52,
                  height: size * .72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.cyan, AppColors.blue],
                    ),
                    borderRadius: BorderRadius.circular(size * .34),
                  ),
                ),
              ),
            ),
            Transform.translate(
              offset: Offset(size * .18, size * .11),
              child: Transform.rotate(
                angle: .32,
                child: Container(
                  width: size * .38,
                  height: size * .56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFB5A7FF), AppColors.purple],
                    ),
                    borderRadius: BorderRadius.circular(size * .30),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
