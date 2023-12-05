import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:flutter/material.dart';

class ActivityChart extends StatelessWidget {
  final List<charts.Series<dynamic, DateTime>> seriesList;
  final bool animate;

  const ActivityChart(this.seriesList, {this.animate = false, super.key});

  @override
  Widget build(BuildContext context) {
    // make axes vivid
    final axisColor = Theme.of(context).brightness == Brightness.dark
        ? charts.MaterialPalette.teal.shadeDefault
        : charts.MaterialPalette.indigo.shadeDefault;
    // time series chart with bar renderer
    return charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      defaultRenderer: charts.BarRendererConfig<DateTime>(),
      defaultInteractions: false,
      behaviors: [charts.SelectNearest(), charts.DomainHighlighter()],
      domainAxis: charts.DateTimeAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(fontSize: 14, color: axisColor),
          lineStyle: charts.LineStyleSpec(color: axisColor),
        ),
      ),
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          labelStyle: charts.TextStyleSpec(fontSize: 14, color: axisColor),
          lineStyle: charts.LineStyleSpec(color: axisColor),
        ),
      ),
    );
  }
}
