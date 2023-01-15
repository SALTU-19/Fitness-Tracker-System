import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class LineChart extends StatelessWidget {
  final data1 = [
    ProductData(0, 20),
    ProductData(1, 17),
    ProductData(2, 42),
    ProductData(3, 12),
    ProductData(4, 30),
  ];

  final data2 = [
    ProductData(0, 32),
    ProductData(1, 11),
    ProductData(2, 22),
    ProductData(3, 12),
    ProductData(4, 5),
  ];

  final data3 = [
    ProductData(0, 6),
    ProductData(1, 15),
    ProductData(2, 20),
    ProductData(3, 31),
    ProductData(4, 8),
  ];

  _getSeriesData() {
    List<charts.Series<ProductData, int>> series = [
      charts.Series(
          id: "Product 1",
          data: data1,
          domainFn: (ProductData series, _) => series.dataX,
          measureFn: (ProductData series, _) => series.dataY,
          colorFn: (ProductData series, _) =>
              charts.MaterialPalette.indigo.shadeDefault),
      charts.Series(
          id: "Product 2",
          data: data2,
          domainFn: (ProductData series, _) => series.dataX,
          measureFn: (ProductData series, _) => series.dataY,
          colorFn: (ProductData series, _) =>
              charts.MaterialPalette.deepOrange.shadeDefault),
      charts.Series(
          id: "Product 3",
          data: data3,
          domainFn: (ProductData series, _) => series.dataX,
          measureFn: (ProductData series, _) => series.dataY,
          colorFn: (ProductData series, _) =>
              charts.MaterialPalette.cyan.shadeDefault)
    ];
    return series;
  }

  @override
  Widget build(BuildContext context) {
    return charts.LineChart(
      _getSeriesData(),
      primaryMeasureAxis:
          const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
      domainAxis:
          const charts.NumericAxisSpec(renderSpec: charts.NoneRenderSpec()),
      animate: true,
    );
  }
}

class ProductData {
  final int dataX;
  final int dataY;

  ProductData(this.dataX, this.dataY);
}
