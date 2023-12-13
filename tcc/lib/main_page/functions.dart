import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

//cria caixa com titulo e conteudo
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

//ordena informacao aleatoria do firebase para uma lista
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

//retorna um unico valor dentro da lista do firebase
double? getValueForKey(String key, Map<String, double> sortedData) {
  return sortedData[key];
}

//valor de consumo total em kWh
double? consumoTotal(Map<String, double> values, DateTime? alterDataIni, DateTime? alterDataFim) {
  double? total = 0;

  if ((alterDataIni != DateTime(1999, 1, 1)) && (alterDataFim != DateTime(1999, 1, 1))) {
    for (String key in values.keys) {
      // Custom parsing of date and time components from the key
      List<String> components = key.split('T');
      if (components.length == 2) {
        List<String> dateComponents = components[0].split('-');
        List<String> timeComponents = components[1].split(':');

        if (dateComponents.length == 3 && timeComponents.length == 3) {
          int year = int.tryParse(dateComponents[2]) ?? 0;
          int month = int.tryParse(dateComponents[1]) ?? 0;
          int day = int.tryParse(dateComponents[0]) ?? 0;
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          int minute = int.tryParse(timeComponents[1]) ?? 0;
          int second = int.tryParse(timeComponents[2]) ?? 0;

          DateTime dateTime = DateTime(year, month, day, hour, minute, second);

          if (dateTime.isAfter(alterDataIni!) && dateTime.isBefore(alterDataFim!)) {
            double? value = values[key];
            if (value != null) {
              total = total! + value;
            }
          }
        }
      }
    }
  } else {
    for (double? value in values.values) {
      if (value != null) {
        total = total! + value;
      }
    }
  }
  print(total);
  // Limit the result to two decimal places
  return total != null ? double.parse((total / 1000).toStringAsFixed(3)) : null;
}




//pega a data pra primeira coluna da tabela
List<String> formatador(List<String> dataHora, DateTime? alterDataIni, DateTime? alterDataFim) {
  List<String> formattedList = [];

  DateFormat dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm:ss'); // Atualiza o formato com '/' ao invés de '-'

  if ((alterDataIni != DateTime(1999, 1, 1)) && (alterDataFim != DateTime(1999, 1, 1))) {
    for (String dateTimeString in dataHora) {

      List<String> components = dateTimeString.split('T');
      if (components.length == 2) {
        List<String> dateComponents = components[0].split('-');
        List<String> timeComponents = components[1].split(':');

        if (dateComponents.length == 3 && timeComponents.length == 3) {
          int year = int.tryParse(dateComponents[2]) ?? 0;
          int month = int.tryParse(dateComponents[1]) ?? 0;
          int day = int.tryParse(dateComponents[0]) ?? 0;
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          int minute = int.tryParse(timeComponents[1]) ?? 0;
          int second = int.tryParse(timeComponents[2]) ?? 0;

          DateTime dateTime = DateTime(year, month, day, hour, minute, second);

          if (dateTime.isAfter(alterDataIni!) && dateTime.isBefore(alterDataFim!)) {
            String formattedDateTime = dateTimeFormat.format(dateTime); // Formata date e time
            formattedList.add('    $formattedDateTime');
          }
        }
      }
    }
  } else {
    for (String dateTimeString in dataHora) {
      // Troca '-' por '/'
      String formattedDateTime = dateTimeString.replaceAll('-', '/');
      // Troca 'T' por espaço
      formattedDateTime = formattedDateTime.replaceAll('T', '  ');

      formattedList.add('    $formattedDateTime');
    }
  }

  return formattedList;
}


//retorna uma lista de valores vindo da lista do firebase
List<String> valores(Map<String, double> values, DateTime? alterDataIni, DateTime? alterDataFim) {
  List<String> sortedKeys = values.keys.toList();
  List<String> data = [];

  if ((alterDataIni != DateTime(1999, 1, 1)) && (alterDataFim != DateTime(1999, 1, 1))) {
    for (String key in sortedKeys) {
      // Custom parsing of date and time components from the key
      List<String> components = key.split('T');
      if (components.length == 2) {
        List<String> dateComponents = components[0].split('-');
        List<String> timeComponents = components[1].split(':');

        if (dateComponents.length == 3 && timeComponents.length == 3) {
          int year = int.tryParse(dateComponents[2]) ?? 0;
          int month = int.tryParse(dateComponents[1]) ?? 0;
          int day = int.tryParse(dateComponents[0]) ?? 0;
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          int minute = int.tryParse(timeComponents[1]) ?? 0;
          int second = int.tryParse(timeComponents[2]) ?? 0;

          DateTime dateTime = DateTime(year, month, day, hour, minute, second);

          if (dateTime.isAfter(alterDataIni!) && dateTime.isBefore(alterDataFim!)) {
            double value = values[key] ?? 0.0;
            data.add((value / 1000).toStringAsFixed(3));
          }
        }
      }
    }
  } else {
    for (String key in sortedKeys) {
      double value = values[key] ?? 0.0;
      data.add((value / 1000).toStringAsFixed(3));
    }
  }

  return data;
}


List<TimeData> organizer(Map<String, double> values, DateTime? alterDataIni, DateTime? alterDataFim) {
  List<String> sortedKeys = values.keys.toList();
  List<TimeData> data = [];

  if ((alterDataIni != DateTime(1999, 1, 1)) && (alterDataFim != DateTime(1999, 1, 1))) {
    for (int i = 0; i < sortedKeys.length; i++) {
      List<String> keyParts = sortedKeys[i].split('T');
      if (keyParts.length == 2) {
        List<String> dateComponents = keyParts[0].split('-');
        List<String> timeComponents = keyParts[1].split(':');

        if (dateComponents.length == 3 && timeComponents.length == 3) {
          int year = int.tryParse(dateComponents[2]) ?? 0;
          int month = int.tryParse(dateComponents[1]) ?? 0;
          int day = int.tryParse(dateComponents[0]) ?? 0;
          int hour = int.tryParse(timeComponents[0]) ?? 0;
          int minute = int.tryParse(timeComponents[1]) ?? 0;
          int second = int.tryParse(timeComponents[2]) ?? 0;

          DateTime dateTime = DateTime(year, month, day, hour, minute, second);

          if (dateTime.isAfter(alterDataIni!) && dateTime.isBefore(alterDataFim!)) {
            String timePart = keyParts[1];
            double value = values[sortedKeys[i]]! / 1000;
            data.add(TimeData(timePart, value));
          }
        }
      }
    }
  } else {
    int startIndex;

    if (sortedKeys.length < 45){
      startIndex = 0;
    } else {
      startIndex = sortedKeys.length - 45;
    }

    for (int i = startIndex; i < sortedKeys.length; i++) {
      List<String> keyParts = sortedKeys[i].split('T');
      if (keyParts.length == 2) {
        String timePart = keyParts[1];
        data.add(TimeData(timePart, (values[sortedKeys[i]]! / 1000)));
      }
    }
  }

  return data;
}


//Monta o gráfico
Column graph(List<TimeData> data) {
  return Column(
    children: [
      Container(
        color: Colors.white, // Define a cor de fundo como branca
        width: 400, // Defina a largura desejada do gráfico
        height: 370, // Defina a altura desejada do gráfico
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
            title: AxisTitle(
              text: 'Tempo',
              alignment: ChartAlignment.center,
              textStyle: const TextStyle(
                fontSize: 14, // Tamanho da fonte da legenda
                fontWeight: FontWeight.bold, // Estilo da fonte da legenda
              ),
            ),
            labelRotation: -90,
          ),
          primaryYAxis: NumericAxis(
            title: AxisTitle(
              text: 'Potência [kW]',
              alignment: ChartAlignment.center,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          legend: const Legend(isVisible: false),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'Potência [kW]: point.y', // Formato do Tooltip
          ),
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
  final String? minute;
  final double kwh;

  TimeData(this.minute, this.kwh);
}


// Function to generate a DataTable
Widget buildDataTable(Map<String, double> values, DateTime alterDataIni, alterDataFim) {
  List<String> coluna1 = formatador(values.keys.toList(), alterDataIni, alterDataFim);
  List<String> coluna2 = valores(values, alterDataIni, alterDataFim);

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
          Center( // Center-align the text within the cell
            child: Text(
              coluna2[index],
              style: TextStyle(color: Colors.white), // Set text color to white
            ),
          ),
        ),
      ],
    ),
  );

  return SingleChildScrollView(
    child: Container(
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text(
              '              Data e Hora',
              style: TextStyle(color: Colors.white),
            ),
          ),
          DataColumn(
            label: Text(
              'Potência [kW]',
              style: TextStyle(color: Colors.white),
            ),
            numeric: true, // Set the second column as numeric for wider width
          ),
        ],
        rows: dataRows,
        // Add a border with specified width, color, and divider thickness
        border: TableBorder.all(
          width: 5.0, // Set the width of the border
          color: Colors.black, // Set the color of the border
        ),
      ),
    ),
  );
}
