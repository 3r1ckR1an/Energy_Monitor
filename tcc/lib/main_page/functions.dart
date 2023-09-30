import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';

Column boxes(String above, String content){
  return Column(
    children: [
      Column(
        children: [
          Text(
            above,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          Container(
            width: 150,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ],
  );
}


Map<String, double> sortFirebaseDataByDateTime(String data) {
  Map<String, dynamic> mapData = Map<String, dynamic>.from(json.decode(data));

  List<String> keys = mapData.keys.toList();
  keys.sort((a, b) {
    // Split the string to parse date and time separately
    List<String> partsA = a.split('T');
    List<String> partsB = b.split('T');

    DateTime dateTimeA = DateTime(
      int.parse(partsA[0].split('-')[2]),
      int.parse(partsA[0].split('-')[0]),
      int.parse(partsA[0].split('-')[1]),
      int.parse(partsA[1].split(':')[0]),
      int.parse(partsA[1].split(':')[1]),
      int.parse(partsA[1].split(':')[2]),
    );

    DateTime dateTimeB = DateTime(
      int.parse(partsB[0].split('-')[2]),
      int.parse(partsB[0].split('-')[0]),
      int.parse(partsB[0].split('-')[1]),
      int.parse(partsB[1].split(':')[0]),
      int.parse(partsB[1].split(':')[1]),
      int.parse(partsB[1].split(':')[2]),
    );

    return dateTimeA.compareTo(dateTimeB);
  });

  // Create a sorted map based on the sorted keys
  Map<String, double> sortedData = {};
  for (String key in keys) {
    sortedData[key] = mapData[key] is double ? mapData[key] : 0.0;
  }

  return sortedData;
}


double? getValueForKey(String key, Map<String, double> sortedData) {
  return sortedData[key];
}


Column Graph() {
  List<TimeData> data = [
    TimeData('1', 0.05702),
    TimeData('2', 0.29888),
    TimeData('3', 0.2824),
    TimeData('4', 0.29527),
    TimeData('5', 0.28148),
    TimeData('6', 0.27815),
    TimeData('7', 0.27995),
    TimeData('8', 0.31281),
    TimeData('9', 0.103),
    TimeData('10', 0.56864),
    TimeData('11', 0.56569),
    TimeData('12', 0.55749),
    TimeData('13', 0.55534),
    TimeData('14', 0.0445),
    TimeData('15', 0.04738),
  ];

  return Column(
    children: [
      Container(
        color: Colors.white, // Set the background color to white
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: AxisTitle(text: 'Horas'), // Legenda do Eixo X
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Consumo em kW'), // Legenda do Eixo Y
          ),
          legend: const Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<TimeData, String>>[
            LineSeries<TimeData, String>(
              dataSource: data,
              xValueMapper: (TimeData sales, _) => sales.minute,
              yValueMapper: (TimeData sales, _) => sales.kwh,
              name: 'Consumo em kWh',
              dataLabelSettings: const DataLabelSettings(
                isVisible: false,
              ),
            ),
          ],
        ),
      ),
      Container( // Custom legend
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 20, // Adjust the width as needed
              height: 8, // Adjust the height as needed
              color: Colors.blue, // Color marker symbol
            ),
            const SizedBox(width: 8), // Add spacing between symbol and text
            const Text(
              'Consumo em kWh',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    ],
  );
}








class TimeData{
  final String minute;
  final double kwh;

  TimeData(this.minute, this.kwh);
}



