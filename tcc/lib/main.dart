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
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child("");
  late double consumo = 0;
  String avatarImagePath = 'assets/on.png';


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: const Text('Monitoramento de Energia'),
          centerTitle: true,
          backgroundColor: Colors.grey[850],
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'HOME'),
              Tab(text: 'TABELA'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: CircleAvatar(
                      backgroundImage: AssetImage(avatarImagePath),
                      radius: 40,
                    ),
                  ),
                  Divider(
                    height: 30,
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
                          setState(() {
                            avatarImagePath = 'assets/on.png'; // Update image path for 'on' state
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          fixedSize: MaterialStateProperty.all(Size(150, 50)),
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
                          setState(() {
                            avatarImagePath = 'assets/off.png'; // Update image path for 'on' state
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          fixedSize: MaterialStateProperty.all(Size(150, 50)),
                        ),
                        child: const Text(
                          'Desligar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  FutureBuilder<DatabaseEvent>(
                    future: ref.child('Power').once(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Text('No data available');
                      } else {
                        // You can access the DataSnapshot from the DatabaseEvent
                        DataSnapshot dataSnapshot = snapshot.data!.snapshot;

                        var value = dataSnapshot.value;

                        String data = value.toString();
                        Map<String, double> sortedData = sortFirebaseDataByDateTime(data);
                        consumo = consumoTotal(sortedData)!;
                        return graph(organizer(sortedData));
                      }
                    },
                  ),
                  const SizedBox(height: 5),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: <Widget>[
                        const SizedBox(width: 15),
                        boxes('Consumo Total:', '${consumo!} kWh'),
                        const SizedBox(width: 17),
                        boxes('Valor:', 'R\$ ' '${(consumo! * 0.89).toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tab 2 - Table
            FutureBuilder<DatabaseEvent>(
              future: ref.child('Power').once(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Text('No data available');
                } else {
                  // You can access the DataSnapshot from the DatabaseEvent
                  DataSnapshot dataSnapshot = snapshot.data!.snapshot;

                  var value = dataSnapshot.value;

                  String data = value.toString();
                  Map<String, double> sortedData = sortFirebaseDataByDateTime(data);

                  return buildDataTable(sortedData);
                }
              },
            ),

            //buildDataTable(),
          ],
        ),
      ),
    );
  }
}
