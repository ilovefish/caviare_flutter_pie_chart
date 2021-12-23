import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:caviare_flutter_pie_chart/pie_chart.dart';

class PieChartPainter extends CustomPainter {
  List<Paint> _paintList = [];
  late List<double> _subParts;
  List<String>? _subTitles;
  double _total = 0;
  double _totalAngle = math.pi * 2;

  final TextStyle? chartValueStyle;
  final Color? chartValueBackgroundColor;
  final double? initialAngle;
  final bool? showValuesInPercentage;
  final bool showChartValues;
  final bool showChartValuesOutside;
  final int? decimalPlaces;
  final bool? showChartValueLabel;
  final ChartType? chartType;
  final String? centerText;
  final TextStyle? centerTextStyle;
  final Function? formatChartValues;
  final double? strokeWidth;
  final Color? emptyColor;
  final List<List<Color>>? gradientList;
  final List<Color>? emptyColorGradient;

  double _prevAngle = 0;

  PieChartPainter(double angleFactor, this.showChartValues,
      this.showChartValuesOutside, List<Color> colorList,
      {this.chartValueStyle,
      this.chartValueBackgroundColor,
      required List<double> values,
      List<String>? titles,
      this.initialAngle,
      this.showValuesInPercentage,
      this.decimalPlaces,
      this.showChartValueLabel,
      this.chartType,
      this.centerText,
      this.centerTextStyle,
      this.formatChartValues,
      this.strokeWidth,
      this.emptyColor,
      this.gradientList,
      this.emptyColorGradient}) {
    _total = values.fold(0, (v1, v2) => v1 + v2);
    if (gradientList?.isEmpty ?? true) {
      for (int i = 0; i < values.length; i++) {
        final paint = Paint()..color = getColor(colorList, i);
        if (chartType == ChartType.ring) {
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = strokeWidth!;
        }
        _paintList.add(paint);
      }
    }
    _totalAngle = angleFactor * math.pi * 2;
    _subParts = values;
    _subTitles = titles;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var side = size.width < size.height ? size.width : size.height;
    side -= 50;
    if (_total == 0) {
      final paint = Paint()..color = emptyColor!;
      if (chartType == ChartType.ring) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth!;
      }
      canvas.drawArc(
        new Rect.fromLTWH(25, 25, side, side),
        _prevAngle,
        360,
        chartType == ChartType.disc ? true : false,
        paint,
      );
    } else {
      final paint = Paint()..color = emptyColor!;
      if (chartType == ChartType.ring) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth!;
      }
      canvas.drawArc(
        new Rect.fromLTWH(25, 25, side, side),
        _prevAngle,
        360,
        chartType == ChartType.disc ? true : false,
        paint,
      );
      final paint2 = Paint()..color = Color(0xFF594F5E);
      if (chartType == ChartType.ring) {
        paint2.style = PaintingStyle.stroke;
        paint2.strokeWidth = 2;
      }
      canvas.drawArc(
        new Rect.fromLTWH(25 - 10, 25 - 10, side + 20, side + 20),
        _prevAngle,
        360,
        chartType == ChartType.disc ? true : false,
        paint2,
      );
      for (int i = 0; i < 8; i++) {
        final radius = showChartValuesOutside ? (side / 2) - 20 : side / 3;
        final x = (radius) * math.cos(45 * i * math.pi / 180);
        final y = (radius) * math.sin(45 * i * math.pi / 180);
        final x2 = x + 25;
        final y2 = y + 25;
        _drawName(canvas, ((i * 3 + 6) % 24).toString(), x2, y2, side);
      }

      // final radius = showChartValuesOutside ? (side / 2) + 16 : side / 3;
      // final x = (radius) * math.cos(270 * math.pi / 180);
      // final y = (radius) * math.sin(270 * math.pi / 180);
      // final x2 = x + 0;
      // final y2 = y + 0;
      // _drawName(canvas, (7 * 3 + 3).toString(), x2, y2,
      //     x >= 0 || y <= 0 ? side + 60 : side - 60);
      // _drawName(
      //     canvas, '24', x2, y2, x2 <= 0 || y2 <= 0 ? side + 80 : side - 80);

      _prevAngle = this.initialAngle! * math.pi / 180;
      final isGradientPresent = gradientList?.isNotEmpty ?? false;
      final isNonGradientElementPresent =
          (_subParts.length - (gradientList?.length ?? 0)) > 0;
      for (int i = 0; i < _subParts.length; i++) {
        if (isGradientPresent) {
          final Rect _boundingSquare = Rect.fromLTWH(25, 25, side, side);
          final _endAngle = (((_totalAngle) / _total) * _subParts[i]);
          final paint = Paint();

          final _normalizedPrevAngle = (_prevAngle - 0.15) % (math.pi * 2);
          final _normalizedEndAngle = (_endAngle + 0.15) % (math.pi * 2);
          final Gradient _gradient = SweepGradient(
            transform: GradientRotation(_normalizedPrevAngle),
            endAngle: _normalizedEndAngle,
            colors: getGradient(gradientList!, i,
                isNonGradientElementPresent: isNonGradientElementPresent,
                emptyColorGradient: emptyColorGradient!),
          );
          paint.shader = _gradient.createShader(_boundingSquare);
          if (chartType == ChartType.ring) {
            paint.style = PaintingStyle.stroke;
            paint.strokeWidth = strokeWidth!;
            paint.strokeCap = StrokeCap.round;
          }
          canvas.drawArc(
            _boundingSquare,
            _prevAngle,
            _endAngle,
            chartType == ChartType.disc ? true : false,
            paint,
          );
        } else {
          canvas.drawArc(
            new Rect.fromLTWH(25, 25, side, side),
            _prevAngle,
            (((_totalAngle) / _total) * _subParts[i]),
            chartType == ChartType.disc ? true : false,
            _paintList[i],
          );
        }
        final radius = showChartValuesOutside ? (side / 2) + 16 : side / 3;
        final cosx = ((((_totalAngle) / _total) * _subParts[i]) / 2);
        final cosy = ((((_totalAngle) / _total) * _subParts[i]) / 2);
        final x = (radius) * math.cos(_prevAngle + cosx);
        final y = (radius) * math.sin(_prevAngle + cosy);
        if (_subParts.elementAt(i) > 0) {
          final value = formatChartValues != null
              ? formatChartValues!(_subParts.elementAt(i))
              : _subParts.elementAt(i).toStringAsFixed(this.decimalPlaces!);

          if (showChartValues) {
            final name = showValuesInPercentage!
                ? (((_subParts.elementAt(i) / _total) * 100)
                        .toStringAsFixed(this.decimalPlaces!) +
                    '%')
                : value;
            final x2 = x + 20;
            final y2 = y + 20;
            // _drawName(
            //     canvas, name, x2, y2, x <= 0 || y <= 0 ? side + 60 : side - 60);
          }
        }
        _prevAngle = _prevAngle + (((_totalAngle) / _total) * _subParts[i]);
      }
    }

    if (centerText != null && centerText!.trim().isNotEmpty) {
      _drawCenterText(canvas, side);
    }
  }

  void _drawCenterText(Canvas canvas, double side) {
    _drawName(canvas, centerText, 0, 0, side, style: centerTextStyle);
  }

  void _drawName(
    Canvas canvas,
    String? name,
    double x,
    double y,
    double side, {
    TextStyle? style,
  }) {
    TextSpan span = TextSpan(
      style: style ?? chartValueStyle,
      text: name,
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();

    if (showChartValueLabel!) {
      //Draw text background box
      final rect = Rect.fromCenter(
        center: Offset((side / 2 + x), (side / 2 + y)),
        width: tp.width + 6,
        height: tp.height + 4,
      );
      final rRect = RRect.fromRectAndRadius(rect, Radius.circular(4));
      final paint = Paint()
        ..color = chartValueBackgroundColor ?? Colors.grey[200]!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rRect, paint);
    }
    //Finally paint the text above box
    tp.paint(
      canvas,
      new Offset(
        (side / 2 + x) - (tp.width / 2),
        (side / 2 + y) - (tp.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) =>
      oldDelegate._totalAngle != _totalAngle;
}
