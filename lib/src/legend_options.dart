import 'package:caviare_flutter_pie_chart/pie_chart.dart';
import 'package:caviare_flutter_pie_chart/src/utils.dart';
import 'package:flutter/material.dart';

class LegendOptions {
  final bool showLegends;
  final bool showLegendsInRow;
  final TextStyle legendTextStyle;
  final BoxShape legendShape;
  final LegendPosition legendPosition;

  const LegendOptions({
    this.showLegends = true,
    this.showLegendsInRow = false,
    this.legendTextStyle = defaultLegendStyle,
    this.legendShape = BoxShape.circle,
    this.legendPosition = LegendPosition.right,
  });
}
