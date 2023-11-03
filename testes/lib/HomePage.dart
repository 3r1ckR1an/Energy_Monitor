import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class HomePage extends StatelessWidget{

  List<SalesData> data = [
    SalesData('20', 0.01588),
    SalesData('21', 0.15411),
    SalesData('22', 0.01650),
    SalesData('23', 0.21140),
    SalesData('24', 0.01634)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Line Chart"),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Container(
        child: Column(
          children: [
            SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              legend: Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
              series: <ChartSeries<SalesData, String>>[
                LineSeries<SalesData, String>(
                  dataSource: data,
                  xValueMapper: (SalesData sales, _) => sales.minute,
                  yValueMapper: (SalesData sales, _) => sales.kwh,
                  name: 'Consumo em kWh',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SalesData{
  final String minute;
  final double kwh;

  SalesData(this.minute, this.kwh);
}