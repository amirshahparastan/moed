import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Chevron فیزیکی مستقل از Directionality.
/// به‌جای Material icons جهت‌دار استفاده می‌شود تا RTL/LTR هیچ‌وقت آن را Mirror نکند.
class PhysicalChevron extends StatelessWidget {
  final bool pointsLeft;
  final Color? color;
  final double size;
  final double strokeWidth;

  const PhysicalChevron.left({
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth = 2.2,
  }) : pointsLeft = true;

  const PhysicalChevron.right({
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth = 2.2,
  }) : pointsLeft = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _ChevronPainter(
          pointsLeft: pointsLeft,
          color: color ?? (dark ? AppColors.mutedDark : AppColors.muted),
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  final bool pointsLeft;
  final Color color;
  final double strokeWidth;

  const _ChevronPainter({
    required this.pointsLeft,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    if (pointsLeft) {
      path
        ..moveTo(size.width * .64, size.height * .24)
        ..lineTo(size.width * .38, size.height * .50)
        ..lineTo(size.width * .64, size.height * .76);
    } else {
      path
        ..moveTo(size.width * .36, size.height * .24)
        ..lineTo(size.width * .62, size.height * .50)
        ..lineTo(size.width * .36, size.height * .76);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ChevronPainter oldDelegate) =>
      oldDelegate.pointsLeft != pointsLeft ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// بازگشت استاندارد فارسی: دکمه در سمت راست و فلش رو به راست.
class RtlBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? color;

  const RtlBackButton({
    super.key,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'بازگشت',
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      icon: PhysicalChevron.right(
        color: color,
        size: 27,
      ),
    );
  }
}

/// ورود به ردیف/صفحه بعدی: در انتهای ردیف (سمت چپ) و رو به چپ.
class RtlNextIcon extends StatelessWidget {
  final Color? color;
  final double size;

  const RtlNextIcon({
    super.key,
    this.color,
    this.size = 23,
  });

  @override
  Widget build(BuildContext context) => PhysicalChevron.left(
        color: color,
        size: size,
      );
}

/// ماه قبل: از نظر فیزیکی سمت راست و رو به راست.
class RtlPreviousMonthIcon extends StatelessWidget {
  final Color? color;
  final double size;

  const RtlPreviousMonthIcon({
    super.key,
    this.color,
    this.size = 27,
  });

  @override
  Widget build(BuildContext context) => PhysicalChevron.right(
        color: color ?? AppColors.blue,
        size: size,
      );
}

/// ماه بعد: از نظر فیزیکی سمت چپ و رو به چپ.
class RtlNextMonthIcon extends StatelessWidget {
  final Color? color;
  final double size;

  const RtlNextMonthIcon({
    super.key,
    this.color,
    this.size = 27,
  });

  @override
  Widget build(BuildContext context) => PhysicalChevron.left(
        color: color ?? AppColors.blue,
        size: size,
      );
}
