import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main_page/functions.dart';
import 'main_page/login.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: LoginPage(),
  ));
}

class Tcc extends StatefulWidget {
  @override
  _TccState createState() => _TccState();
}

class _TccState extends State<Tcc> {
  bool isLigarEnabled = true;
  bool isDesligarEnabled = true;
  final DatabaseReference ref = FirebaseDatabase.instance.ref().child("");
  late double consumo = 0;
  double tarifa = 0.89;
  int limpou = 0;
  String avatarImagePath = 'assets/on_oficial.png';

  DateTime startDate = DateTime.now();
  late DateTime alterDataIni = DateTime(1999, 1, 1);
  DateTime endDate = DateTime.now();
  late DateTime alterDataFim = DateTime(1999, 1, 1);

  void _onTabChanged(int index) {
    if (index == 0) {
      // Action for HOME tab
      setState(() {});
      // _calculateConsumoTotal();
    } else if (index == 1) {
      // Action for TABELA tab
      _calculateConsumoTotal();
    }
  }

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

      if (limpou == 1){
        alterDataIni = DateTime(1999, 1, 1);
        alterDataFim = DateTime(1999, 1, 1);
      }

      double totalConsumo = consumoTotal(sortedData, alterDataIni, alterDataFim) ?? 0;
      setState(() {
        consumo = totalConsumo;
      });
    } catch (e) {
      print('Error: $e');
      // Handle the error appropriately if needed
    }

    limpou = 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          leading: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 90.0),
                child: Image.asset(
                  'assets/AppBar_oficial.png',
                  width: 170,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          centerTitle: true,
          backgroundColor: Colors.grey[850],
          elevation: 0,
          bottom: TabBar(
            tabs: [
              Tab(text: 'HOME'),
              Tab(text: 'TABELA'),
            ],
            onTap: _onTabChanged,
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
                  SizedBox(
                    height: 130, // Adjust the height as needed
                    child: Center(
                      child: CircleAvatar(
                        backgroundImage: AssetImage(avatarImagePath),
                        radius: 40,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: isLigarEnabled
                            ? () {
                          ref.update({
                            "Led_Status": 'on',
                          });
                          setState(() {
                            avatarImagePath = 'assets/on_oficial.png';
                            isLigarEnabled = false;
                            isDesligarEnabled = true;
                          });
                        }
                            : null, // Set onPressed to null when disabled
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          fixedSize: MaterialStateProperty.all(Size(140, 50)),
                        ),
                        child: const Text(
                          'Ligar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        onPressed: isDesligarEnabled
                            ? () {
                          ref.update({
                            "Led_Status": 'off',
                          });
                          setState(() {
                            avatarImagePath = 'assets/off_oficial.png';
                            isLigarEnabled = true;
                            isDesligarEnabled = false;
                          });
                        }
                            : null, // Set onPressed to null when disabled
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.red),
                          fixedSize: MaterialStateProperty.all(Size(140, 50)),
                        ),
                        child: const Text(
                          'Desligar',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                  Divider(
                    height: 20,
                    color: Colors.grey[350],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '            Consumo de Energia Elétrica',
                    style: TextStyle(
                      fontSize: 16, // Adjust the font size as needed
                      fontWeight: FontWeight.bold, // You can change the font weight if desired
                      color: Colors.white, // Set the text color to white
                    ),
                  ),
                  const SizedBox(height: 5),
                  buildConsumptionGraph(),
                ],
              ),
            ),
            // Tab 2 - 'TABELA' tab
            ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 11),
                          IconButton(
                            onPressed: () {
                              _showTarifaDialog(context);
                            },
                            icon: Icon(Icons.monetization_on), // Money icon
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 243),
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
                    Container(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(width: 25),
                          boxes('Consumo Total:', '${consumo!} kWh'),
                          const SizedBox(width: 10),
                          boxes('Valor:', 'R\$ ' '${(consumo! * tarifa).toStringAsFixed(2)}'),
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

  Widget buildConsumptionGraph() {
    return FutureBuilder<DatabaseEvent>(
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
          return graph(organizer(sortedData, alterDataIni, alterDataFim));
        }
      },
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

        final buttonStyle = ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Change the button color to your preference
          foregroundColor: Colors.white, // Change the text color to your preference
          minimumSize: Size(120, 40), // Adjust the button size as needed
        );

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
                      SizedBox(width: 10.0),
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
                      Text('Fim:   '),
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
                  SizedBox(height: 16.0),
                ],
              );
            },
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      startDate = DateTime.now();
                      endDate = DateTime.now();
                      alterDataIni = DateTime(1999, 1, 1);
                      alterDataFim = DateTime(1999, 1, 1);
                    });
                    Navigator.of(context).pop([startDate, endDate]);
                    limpou = 1;
                    _calculateConsumoTotal();
                  },
                  style: buttonStyle, // Apply the custom style to the button
                  child: Text('Limpar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop([
                      DateTime(selectedStartDate.year, selectedStartDate.month, selectedStartDate.day, selectedStartTime.hour, selectedStartTime.minute),
                      DateTime(selectedEndDate.year, selectedEndDate.month, selectedEndDate.day, selectedEndTime.hour, selectedEndTime.minute),
                    ]);
                    _calculateConsumoTotal();
                  },
                  style: buttonStyle, // Apply the custom style to the button
                  child: Text('Filtrar'),
                ),
              ],
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
      alterDataIni = startDate;
      alterDataFim = endDate;
    }
  }




  Widget _buildDateButton(DateTime date, Function(DateTime) onDateSelected) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(date); // Format the date as 'day-month-year'
    return Container(
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
                  Align(
                    alignment: Alignment.centerLeft, // Adjust alignment as needed
                    child: Text('Insira o valor da Tarifa (R\$):'),
                  ),
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
            Align(
              alignment: Alignment.bottomCenter, // Center at the bottom
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(newTarifa);
                  _calculateConsumoTotal();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Change the button color to your preference
                  foregroundColor: Colors.white, // Change the text color to your preference
                  minimumSize: Size(120, 40), // Adjust the button size as needed
                ),
                child: Text('Salvar'),
              ),
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
