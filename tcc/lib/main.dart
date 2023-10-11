import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page/functions.dart';
import 'package:intl/intl.dart';

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
  double tarifa = 0.89;
  String avatarImagePath = 'assets/on.png';

  DateTime startDate = DateTime.now();
  late DateTime alterDataIni = DateTime(1999, 1, 1);
  DateTime endDate = DateTime.now();
  late DateTime alterDataFim = DateTime(1999, 1, 1);

  @override
  void initState() {
    super.initState();
    // Call your calculateConsumoTotal function here
    _calculateConsumoTotal();
  }

  _calculateConsumoTotal() async {
    try {
      DataSnapshot dataSnapshot = (await ref.child('Power').once()).snapshot;
      var value = dataSnapshot.value;
      String data = value.toString();
      Map<String, double> sortedData = sortFirebaseDataByDateTime(data);
      double totalConsumo = consumoTotal(sortedData, alterDataIni, alterDataFim) ?? 0;
      setState(() {
        consumo = totalConsumo;
      });
    } catch (e) {
      print('Error: $e');
      // Handle the error appropriately if needed
    }
  }

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
                            avatarImagePath = 'assets/on.png';
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
                            avatarImagePath = 'assets/off.png';
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
                        DataSnapshot dataSnapshot = snapshot.data!.snapshot;

                        var value = dataSnapshot.value;

                        String data = value.toString();
                        Map<String, double> sortedData = sortFirebaseDataByDateTime(data);
                        consumo = consumoTotal(sortedData, alterDataIni, alterDataFim)!;
                        return graph(organizer(sortedData));
                      }
                    },
                  ),
                ],
              ),
            ),
            // Tab 2 - 'TABELA' tab
            ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Container(
                      child: Row(
                        children: <Widget>[
                          //const SizedBox(width: 40),
                          IconButton(
                            onPressed: () {
                              _showTarifaDialog(context);
                            },
                            icon: Icon(Icons.monetization_on), // Money icon
                            color: Colors.blue,
                          ),
                          boxes('Consumo Total:', '${consumo!} kWh'),
                          const SizedBox(width: 15),
                          boxes('Valor:', 'R\$ ' '${(consumo! * tarifa).toStringAsFixed(2)}'),
                          IconButton(
                            onPressed: () {
                              _showDateFilterDialog(context);
                            },
                            icon: Icon(Icons.filter_list),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
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
                          DataSnapshot dataSnapshot = snapshot.data!.snapshot;

                          var value = dataSnapshot.value;

                          String data = value.toString();
                          Map<String, double> sortedData = sortFirebaseDataByDateTime(data);

                          return buildDataTable(sortedData, alterDataIni, alterDataFim);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateFilterDialog(BuildContext context) async {
    final selectedDates = await showDialog<List<DateTime>>(
      context: context,
      builder: (context) {
        DateTime selectedStartDate = startDate;
        DateTime selectedEndDate = endDate;
        TimeOfDay selectedStartTime = TimeOfDay.fromDateTime(startDate);
        TimeOfDay selectedEndTime = TimeOfDay.fromDateTime(endDate);

        return AlertDialog(
          title: Text('Filtrar por Data e Hora'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Selecione a data e hora de início e a data e hora de fim:'),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text('Início:'),
                      SizedBox(width: 10.0),//
                      _buildDateButton(
                        selectedStartDate,
                            (selectedDate) {
                          setState(() {
                            selectedStartDate = selectedDate;
                          });
                        },
                      ),
                      _buildTimeButton(
                        selectedStartTime,
                            (selectedTime) {
                          setState(() {
                            selectedStartTime = selectedTime;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text('Fim:'),
                      SizedBox(width: 10.0),
                      _buildDateButton(
                        selectedEndDate,
                            (selectedDate) {
                          setState(() {
                            selectedEndDate = selectedDate;
                          });
                        },
                      ),
                      _buildTimeButton(
                        selectedEndTime,
                            (selectedTime) {
                          setState(() {
                            selectedEndTime = selectedTime;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop([
                  DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day, selectedStartTime.hour, selectedStartTime.minute),
                  DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute),
                ]);
                _calculateConsumoTotal();
              },
              child: Text('Filtrar'),
            ),
          ],
        );
      },
    );

    if (selectedDates != null && selectedDates.isNotEmpty) {
      setState(() {
        startDate = selectedDates[0];
        endDate = selectedDates[1];
      });
      // Add your filter logic here using startDate and endDate
      // For example: Apply the date filter to your data
      alterDataIni = startDate;
      alterDataFim = endDate;
    }
  }

  Widget _buildDateButton(DateTime date, Function(DateTime) onDateSelected) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date); // Format the date as 'day-month-year'
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (selectedDate != null) {
                onDateSelected(selectedDate);
              }
            },
            child: Text(formattedDate),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(TimeOfDay time, Function(TimeOfDay) onTimeSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        children: [
          TextButton(
            onPressed: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (selectedTime != null) {
                onTimeSelected(selectedTime);
              }
            },
            child: Text(time.format(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _showTarifaDialog(BuildContext context) async {
    final newTarifa = await showDialog<double>(
      context: context,
      builder: (context) {
        double newTarifa = tarifa;

        return AlertDialog(
          title: Text('Definir Tarifa'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Insira o valor da Tarifa (R\$):'),
                  SizedBox(height: 16.0),
                  TextFormField(
                    initialValue: newTarifa.toString(),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      newTarifa = double.tryParse(value) ?? 0.0;
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(newTarifa);
                _calculateConsumoTotal();
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (newTarifa != null) {
      setState(() {
        tarifa = newTarifa;

      });
    }
  }
}
