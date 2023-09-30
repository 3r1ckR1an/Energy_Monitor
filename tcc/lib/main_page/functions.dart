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


double? consumoTotal(Map<String, double> values) {
  List<String> sortedKeys = values.keys.toList();
  double? total = 0;

  for (int i = 1; i < 16; i++) {
    double? value = getValueForKey(sortedKeys[i - 1], values);
    if (value != null) {
      total = total! + value;
    }
  }
  total = (total!/1000);

  return total;
}

List<String> formatador(List<String> dataHora) {
  List<String> formattedList = [];

  for (String dateTimeString in dataHora) {
    // Replace '-' with '/'
    String formattedDateTime = dateTimeString.replaceAll('-', '/');
    // Replace 'T' with a space
    formattedDateTime = formattedDateTime.replaceAll('T', '  ');

    formattedList.add('  $formattedDateTime');
  }

  return formattedList;
}


List<String> valores(Map<String, double> values) {
  List<String> sortedKeys = values.keys.toList();
  List<String> data = [];

  for (String key in sortedKeys) {
    data.add('           ${getValueForKey(key, values)}');
  }

  return data;
}

List<TimeData> organizer(Map<String, double> values){

  List<String> sortedKeys = values.keys.toList();

  List<TimeData> data = [];

  for(int i = 1; i < 16; i++){
    data.add(TimeData(i.toString(), ((getValueForKey(sortedKeys[i - 1], values))!/1000)));
  }

  return data;
}


Column graph(List<TimeData> data) {
  return Column(
    children: [
      Container(
        color: Colors.white, // Set the background color to white
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: AxisTitle(text: 'tempo (s)'), // Legenda do Eixo X
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(text: 'Potência [kW]'), // Legenda do Eixo Y
          ),
          legend: const Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ChartSeries<TimeData, String>>[
            LineSeries<TimeData, String>(
              dataSource: data,
              xValueMapper: (TimeData sales, _) => sales.minute,
              yValueMapper: (TimeData sales, _) => sales.kwh,
              name: '',
              dataLabelSettings: const DataLabelSettings(
                isVisible: false,
              ),
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

// Function to generate a DataTable
Widget buildDataTable(Map<String, double> values) {

  //List<String> Keys = formatador(values.keys.toList());

  List<String> coluna1 = formatador(values.keys.toList());
  List<String> coluna2 = valores(values);

  // Ensure that column1Data and column2Data have the same length
  assert(coluna1.length == coluna2.length);

  List<DataRow> dataRows = List<DataRow>.generate(
    coluna1.length,
        (int index) => DataRow(
      cells: <DataCell>[
        DataCell(
          Text(
            coluna1[index],
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
        ),
        DataCell(
          Text(
            coluna2[index],
            style: TextStyle(color: Colors.white), // Set text color to white
          ),
        ),
      ],
    ),
  );


  return SingleChildScrollView(
    child: Container(
      //color: Colors.white,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              '           Data e Hora',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              '     Potência [kW]',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
        rows: dataRows,
        // Add a border with specified width, color, and divider thickness
        border: TableBorder.all(
          width: 5.0, // Set the width of the border
          color: Colors.black, // Set the color of the border
          //dividerThickness: 5, // Set the thickness of the dividers
        ),
      ),
    ),
  );
}

