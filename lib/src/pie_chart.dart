import 'package:caviare_flutter_pie_chart/pie_chart.dart';
import 'package:caviare_flutter_pie_chart/src/chart_values_options.dart';
import 'package:flutter/material.dart';

import 'chart_painter.dart';
import 'legend.dart';
import 'utils.dart';

enum LegendPosition { top, bottom, left, right }

enum ChartType { disc, ring }

class PieChart extends StatefulWidget {
  PieChart({
    required this.dataMap,
    this.chartType = ChartType.disc,
    this.chartRadius,
    this.animationDuration,
    this.chartLegendSpacing = 48,
    this.colorList = defaultColorList,
    this.initialAngleInDegree = 0.0,
    this.formatChartValues,
    this.centerText,
    this.centerTextStyle,
    this.ringStrokeWidth = 20.0,
    this.legendOptions = const LegendOptions(),
    this.chartValuesOptions = const ChartValuesOptions(),
    this.emptyColor = Colors.white,
    this.gradientList,
    this.emptyColorGradient = const [Colors.black26, Colors.black54],
    this.onBuildView,
    Key? key,
  }) : super(key: key);

  final Map<String, double> dataMap;
  final ChartType chartType;
  final double? chartRadius;
  final Duration? animationDuration;
  final double chartLegendSpacing;
  final List<Color> colorList;
  final List<List<Color>>? gradientList;
  final double initialAngleInDegree;
  final Function? formatChartValues;
  final String? centerText;
  final TextStyle? centerTextStyle;
  final double ringStrokeWidth;
  final LegendOptions legendOptions;
  final ChartValuesOptions chartValuesOptions;
  final Color emptyColor;
  final List<Color> emptyColorGradient;
  final List<Widget> Function()? onBuildView;

  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  AnimationController? controller;
  double _animFraction = 0.0;

  List<String>? legendTitles;
  late List<double> legendValues;

  void initLegends() {
    this.legendTitles = widget.dataMap.keys.toList(growable: false);
  }

  void initValues() {
    this.legendValues = widget.dataMap.values.toList(growable: false);
  }

  void initData() {
    assert(
      widget.dataMap != null && widget.dataMap.isNotEmpty,
      "dataMap passed to pie chart cant be null or empty",
    );
    initLegends();
    initValues();
  }

  @override
  void initState() {
    super.initState();
    initData();
    controller = AnimationController(
      duration: widget.animationDuration ?? Duration(milliseconds: 800),
      vsync: this,
    );
    final Animation curve = CurvedAnimation(
      parent: controller!,
      curve: Curves.decelerate,
    );
    animation =
        Tween<double>(begin: 0, end: 1).animate(curve as Animation<double>)
          ..addListener(() {
            setState(() {
              _animFraction = animation.value;
            });
          });
    controller!.forward();
  }

  Widget _getChart() {
    return Expanded(
      flex: 1,
      child: LayoutBuilder(builder: (_, c) {
        return IntrinsicHeight(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Expanded(
              flex: 0,
              child: Container(
                  alignment: Alignment.center,
                  height: widget.chartRadius != null
                      ? c.maxWidth < widget.chartRadius!
                          ? c.maxWidth
                          : widget.chartRadius
                      : null,
                  child: LayoutBuilder(
                    builder: (_, c) {
                      // final size = MediaQuery.of(context).size;
                      // var side = c.maxWidth < c.maxHeight ? c.maxWidth : c.maxHeight;
                      // var whc = (c.maxWidth - c.maxHeight) / 2;
                      // side -= 50;
                      // final radius = widget.chartValuesOptions.showChartValuesOutside
                      //     ? (side / 2) + 16
                      //     : side / 3;
                      //
                      // num _totalAngle = _animFraction * math.pi * 2;
                      // num _prevAngle =
                      //     this.widget.initialAngleInDegree! * math.pi / 180;
                      // num _total = legendValues.fold(0, (v1, v2) => v1 + v2);
                      // List<Widget> buttons = [];
                      // for (int i = 0; i < legendValues.length; i++) {
                      //   List<String> dataStrList = [];
                      //   if (legendTitles != null) {
                      //     dataStrList = legendTitles![i].split('-');
                      //   }
                      //   final x = (radius) *
                      //       math.cos(_prevAngle +
                      //           ((((_totalAngle) / _total) * legendValues[i]) / 2));
                      //   final y = (radius) *
                      //       math.sin(_prevAngle +
                      //           ((((_totalAngle) / _total) * legendValues[i]) / 2));
                      //   _prevAngle = _prevAngle +
                      //       (((_totalAngle) / _total) * legendValues[i]);
                      //   buttons.add(Positioned(
                      //     left: x + side / 2 - 30 + 25 + 45,
                      //     // right: 10,
                      //     bottom: -y + side / 2 - 10 + 25,
                      //     // top: 0,
                      //     child: Container(
                      //       width: 60,
                      //       height: 20,
                      //       alignment: Alignment.center,
                      //       child: Text(dataStrList[3],
                      //           style: TextStyle(
                      //             fontSize: 12,
                      //             color: Colors.red,
                      //           )),
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.rectangle,
                      //         color: Colors.blue.shade200,
                      //         borderRadius: BorderRadius.circular(12.0),
                      //         border: Border.all(
                      //           color: Colors.blue.shade200,
                      //           width: 1,
                      //           style: BorderStyle.solid,
                      //         ),
                      //       ),
                      //     ),
                      //   ));
                      // }
                      return Container(
                        width: c.maxHeight,
                        height: c.maxHeight,
                        child: CustomPaint(
                          painter: PieChartPainter(
                            _animFraction,
                            widget.chartValuesOptions.showChartValues,
                            widget.chartValuesOptions.showChartValuesOutside,
                            widget.colorList,
                            chartValueStyle:
                                widget.chartValuesOptions.chartValueStyle,
                            chartValueBackgroundColor: widget
                                .chartValuesOptions.chartValueBackgroundColor,
                            values: legendValues,
                            titles: legendTitles,
                            initialAngle: widget.initialAngleInDegree,
                            showValuesInPercentage: widget
                                .chartValuesOptions.showChartValuesInPercentage,
                            decimalPlaces:
                                widget.chartValuesOptions.decimalPlaces,
                            showChartValueLabel: widget
                                .chartValuesOptions.showChartValueBackground,
                            chartType: widget.chartType,
                            centerText: widget.centerText,
                            centerTextStyle: widget.centerTextStyle,
                            formatChartValues: widget.formatChartValues,
                            strokeWidth: widget.ringStrokeWidth,
                            emptyColor: widget.emptyColor,
                            gradientList: widget.gradientList,
                            emptyColorGradient: widget.emptyColorGradient,
                          ),
                          child: AspectRatio(aspectRatio: 1),
                        ),
                      );
                    },
                  )),
            ),
            widget.onBuildView != null
                ? Expanded(
                    child: Container(
                      height: 18,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: widget.onBuildView!(),
                      ),
                    ),
                  )
                : Container()
          ]),
        );
      }),
    );
  }

  Widget _getPieChart() {
    switch (widget.legendOptions.legendPosition) {
      case LegendPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getLegend(
              padding: EdgeInsets.only(
                bottom: widget.chartLegendSpacing,
              ),
            ),
            _getChart(),
          ],
        );

      case LegendPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getChart(),
            _getLegend(
              padding: EdgeInsets.only(
                top: widget.chartLegendSpacing,
              ),
            ),
          ],
        );
      case LegendPosition.left:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getLegend(
              padding: EdgeInsets.only(
                right: widget.chartLegendSpacing,
              ),
            ),
            _getChart(),
          ],
        );
      case LegendPosition.right:
        return Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _getChart(),
            // _getLegend(
            //   padding: EdgeInsets.only(
            //     left: widget.chartLegendSpacing,
            //   ),
            // ),
          ],
        );
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _getChart(),
            _getLegend(
              padding: EdgeInsets.only(
                left: widget.chartLegendSpacing,
              ),
            ),
          ],
        );
    }
  }

  _getLegend({EdgeInsets? padding}) {
    if (widget.legendOptions.showLegends) {
      final isGradientPresent = widget.gradientList?.isNotEmpty ?? false;
      final isNonGradientElementPresent =
          (widget.dataMap.length - (widget.gradientList?.length ?? 0)) > 0;
      return Padding(
        padding: padding!,
        child: Wrap(
          direction: widget.legendOptions.showLegendsInRow
              ? Axis.horizontal
              : Axis.vertical,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: legendTitles!
              .map(
                (item) => Legend(
                  title: item,
                  color: isGradientPresent
                      ? getGradient(
                          widget.gradientList!, legendTitles!.indexOf(item),
                          isNonGradientElementPresent:
                              isNonGradientElementPresent,
                          emptyColorGradient: widget.emptyColorGradient)[0]
                      : getColor(
                          widget.colorList,
                          legendTitles!.indexOf(item),
                        ),
                  style: widget.legendOptions.legendTextStyle,
                  legendShape: widget.legendOptions.legendShape,
                ),
              )
              .toList(),
        ),
      );
    } else
      return SizedBox(
        height: 0,
        width: 0,
      );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.0),
      child: _getPieChart(),
    );
  }

  @override
  void didUpdateWidget(PieChart oldWidget) {
    initData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
