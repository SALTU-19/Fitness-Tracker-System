import 'bar_chart_sample.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class BarChartPage extends StatelessWidget {
  const BarChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.neavyBlue,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(28),
          child: BarChartSample2(),
        ),
      ),
    );
  }
}
