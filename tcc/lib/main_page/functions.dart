import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

Column boxes(String above, String content){
  return Column(
    children: [
      Column(
        children: [
          Text(
            above,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.yellow,
            ),
          ),
          Container(
            width: 150,
            height: 150,
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








