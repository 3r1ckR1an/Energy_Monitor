import 'package:flutter/material.dart';

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
            width: 100,
            height: 70,
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
