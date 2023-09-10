import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page/functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: Tcc(),
  ));
}

class Tcc extends StatefulWidget {
  @override
  _TccState createState() => _TccState();
}

class _TccState extends State<Tcc> {
  final DatabaseReference ref =
  FirebaseDatabase.instance.ref().child("");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Monitoramento de Energia'),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Center(
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/lampada.jpg'),
                radius: 40,
              ),
            ),
            Divider(
              height: 35,
              color: Colors.grey[350],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    ref.update({
                      "Led_Status": 'on',
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    fixedSize: MaterialStateProperty.all(Size(100, 50)),
                  ),
                  child: const Text(
                    'Ligar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ref.update({
                      "Led_Status": 'off',
                    });
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    fixedSize: MaterialStateProperty.all(Size(100, 50)),
                  ),
                  child: const Text(
                    'Desligar',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FutureBuilder<DatabaseEvent>(
                  future: ref.child('Power').once(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Text('No data available');
                    } else {
                      // You can access the DataSnapshot from the DatabaseEvent
                      DataSnapshot dataSnapshot = snapshot.data!.snapshot;

                      var value = dataSnapshot.value;

                      String data = value.toString();
                      Map<String, double> sortedData = sortFirebaseDataByDateTime(data);
                      List<String> sortedKeys = sortedData.keys.toList();
                      double? valor = getValueForKey(sortedKeys[3], sortedData);

                      return boxes('Tensão:', valor.toString() + 'V');
                    }
                  },
                ),
                const SizedBox(width: 20),
                // FutureBuilder<DatabaseEvent>(
                //   future: ref.child('Corrente').child('-NdR28oZB-1vn0ZrP2G7').once(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator();
                //     } else if (snapshot.hasError) {
                //       return Text('Error: ${snapshot.error}');
                //     } else if (!snapshot.hasData || snapshot.data == null) {
                //       return Text('No data available');
                //     } else {
                //       // You can access the DataSnapshot from the DatabaseEvent
                //       DataSnapshot dataSnapshot = snapshot.data!.snapshot;
                //       var value = dataSnapshot.value;
                //       return boxes('Corrente:', value.toString() + 'A');
                //     }
                //   },
                // ),
                const SizedBox(width: 20),
                // FutureBuilder<DatabaseEvent>(
                //   future: ref.child('Potencia').child('-NdR28sburAq7HOH_6EM').once(),
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return CircularProgressIndicator();
                //     } else if (snapshot.hasError) {
                //       return Text('Error: ${snapshot.error}');
                //     } else if (!snapshot.hasData || snapshot.data == null) {
                //       return Text('No data available');
                //     } else {
                //       // You can access the DataSnapshot from the DatabaseEvent
                //       DataSnapshot dataSnapshot = snapshot.data!.snapshot;
                //       var value = dataSnapshot.value;
                //       return boxes('Potencia:', value.toString() + 'W');
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}