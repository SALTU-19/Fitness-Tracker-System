// Copyright 2017, Paul DeMarco.
// All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'package:bluetooth_app/globals.dart';
import 'package:csv/csv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'widgets.dart';
import 'constants.dart';
import 'drawer.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:audioplayers/audioplayers.dart';

Future<void> main() async {
  runApp(
    const MaterialApp(
        debugShowCheckedModeBanner: false, home: FlutterBlueApp()),
  );
}

class FlutterBlueApp extends StatefulWidget {
  const FlutterBlueApp({Key? key}) : super(key: key);

  @override
  State<FlutterBlueApp> createState() => _FlutterBlueAppState();
}

class _FlutterBlueAppState extends State<FlutterBlueApp> {
  @override
  Widget build(BuildContext context) {
    FlutterBluePlus.instance.turnOn();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: AppColors.sherpaBlue,
      home: StreamBuilder<BluetoothState>(
          stream: FlutterBluePlus.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;

            return const FindDevicesScreen();
          }),
    );
  }
}

class FindDevicesScreen extends StatefulWidget {
  const FindDevicesScreen({Key? key}) : super(key: key);

  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  final String pulse = 'Pulse Statistics';
  final String pulseSvg = 'assets/pulse.svg';
  final String fitness = 'Fitness Statistics';
  final String fitnessSvg = 'assets/fitness.svg';
  String newDeviceName = '';
  String fileContent = '';

  BluetoothDevice? device;
  bool _isDisconnectButtonDisabled = true;
  List<List<dynamic>> rowsAsListOfValues = [];

  bool _isNewDevice = false;
  int _openFlag = 0;
  bool sitUpBegin = false;
  bool pushUpBegin = false;
  bool pullUpBegin = false;
  bool sitUpEnd = false;
  bool pushUpEnd = false;
  bool pullUpEnd = false;
  double accelX = 0.0;
  double accelY = 0.0;
  double accelZ = 0.0;
  double gyroX = 0.0;
  double gyroY = 0.0;
  double gyroZ = 0.0;
  double heartRate = 0.0;
  String heartRateString = '0.0';
  double value = 0.0;
  double oxygen = 0.0;
  List<List<List<List<dynamic>>>> statistics = [];

  List<String> movementList = <String>[
    'Which Movement',
    'Pull Up',
    'Push Up',
    'Sit Up'
  ];

  void _disconnect() {
    if (device?.name != null) {
      setState(() {
        device?.disconnect();
        _isDisconnectButtonDisabled = true;
        accelX = 0.0;
        accelY = 0.0;
        accelZ = 0.0;
        gyroX = 0.0;
        gyroY = 0.0;
        gyroZ = 0.0;
        heartRate = 0.0;
        heartRateString = '0.0';
        oxygen = 0.0;
        counter = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final audio = AudioCache();
    List<BluetoothService> services = [];
    final String _date = DateFormat.yMMMd().format(DateTime.now());
    final String _day = DateFormat.EEEE().format(DateTime.now());
    String time;
    print(preferredMovement);
    if ((accelX > -4.2 && accelX < 6) && (accelZ > -13.8 && accelZ < -7.5)) {
      sitUpBegin = true;
      print('sitUpBegin');
    }
    if ((accelX > -9.5 && accelX < -5) && (accelZ > -13.8 && accelZ < -5)) {
      pullUpBegin = true;
      print('pullUPBegin');
    }
    if ((accelX > -6 && accelX < -3) && (accelZ > 8 && accelZ < 11)) {
      pushUpBegin = true;
      print('pushUPBegin');
    }

    if ((accelX > -13.2 && accelX < -6) &&
        (accelZ > -5 && accelZ < 7) &&
        sitUpBegin) {
      sitUpEnd = true;
      print('sitUpEnd');
    }
    if ((accelX > -13.2 && accelX < -6) &&
        (accelZ > -5 && accelZ < 7) &&
        pullUpBegin) {
      pullUpEnd = true;
      print('pullUpEnd');
    }
    if ((accelX > -3 && accelX < 2) &&
        (accelZ > 8 && accelZ < 10) &&
        pushUpBegin) {
      pushUpEnd = true;
      print('pushUpEnd');
    }
    if (sitUpBegin && sitUpEnd && sitUpFlag) {
      counter++;
      sitUpBegin = false;
      sitUpEnd = false;
      print('sitUpCounter');
    }
    if (pullUpBegin && pullUpEnd && pullUpFlag) {
      counter++;
      pullUpBegin = false;
      pullUpEnd = false;
      print('pullUpCounter');
    }
    if (pushUpBegin && pushUpEnd && pushUpFlag) {
      counter++;
      pushUpBegin = false;
      pushUpEnd = false;
      print('pushUpCounter');
    }
    if (counter == preferredMovement && counter != 0 && audioFlag) {
      audio.play('congratulations.mp3');
      audioFlag = false;
    }
    setState(() {});

    return Scaffold(
      backgroundColor: AppColors.neavyBlue,
      appBar: AppBar(
        backgroundColor: AppColors.neavyBlue,
        title: const Text("𝙁𝙞𝙩𝙣𝙚𝙨𝙨𝙏𝙧𝙖𝙘𝙠𝙚𝙧"),
        centerTitle: true,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
            ),
            onPressed: _isDisconnectButtonDisabled ? null : _disconnect,
            child: const Text(
              'DISCONNECT',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
      drawer: const DrawerWidget(),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: 20.0, vertical: size.height * 0.03),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Welcome",
                            style:
                                Theme.of(context).textTheme.caption?.copyWith(
                                      color: Colors.white,
                                      fontSize: size.height * 0.015,
                                    )),
                        HeadLine6(
                            color: AppColors.saltMountain,
                            text: "Coskun Saltu",
                            fontSize: size.height * 0.02),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(_date,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w400,
                              fontSize: size.height * 0.02,
                              color: AppColors.saltMountain,
                            )),
                        Text(_day,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w400,
                              fontSize: size.height * 0.02,
                              color: AppColors.saltMountain,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    DropdownButtonExample(),
                    DropdownButtonExample2(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: AppColors.aareRiverBrienz,
                      onPrimary: Colors.black),
                  onPressed: () async =>
                      {counter = 0, audioFlag = true, setState(() {})},
                  child: const Text(
                    'STOP',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 120.0),
                child: Text("Counter: $counter",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: size.height * 0.03,
                      color: AppColors.white,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0),
                child: Text("Heart Rate: $heartRateString",
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.w600,
                      fontSize: size.height * 0.03,
                      color: AppColors.white,
                    )),
              ),
            ]),
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBluePlus.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              onPressed: () {
                FlutterBluePlus.instance.stopScan();
              },
              backgroundColor: Colors.red,
              child: const Icon(Icons.stop),
            );
          } else {
            return FloatingActionButton(
                child: const Icon(Icons.search),
                backgroundColor: AppColors.neavyBlue,
                onPressed: () => showDialog<String>(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        actionsAlignment: MainAxisAlignment.spaceBetween,
                        backgroundColor: AppColors.naturalIndigo,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20.0))),
                        scrollable: true,
                        title: RefreshIndicator(
                          onRefresh: () => FlutterBluePlus.instance
                              .startScan(timeout: const Duration(seconds: 4)),
                          child: SingleChildScrollView(
                            child: Column(
                              children: <Widget>[
                                StreamBuilder<List<BluetoothDevice>>(
                                  stream: Stream.periodic(
                                          const Duration(seconds: 2))
                                      .asyncMap((_) => FlutterBluePlus
                                          .instance.connectedDevices),
                                  initialData: const [],
                                  builder: (c, snapshot) => Column(
                                    children: snapshot.data!
                                        .map((d) => ListTile(
                                              title: Text(d.name),
                                              subtitle: Text(
                                                deviceName(
                                                  d,
                                                ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.copyWith(
                                                        color: AppColors
                                                            .aareRiverBrienz),
                                              ),
                                              trailing: SizedBox(
                                                width: 100,
                                                child: StreamBuilder<
                                                    BluetoothDeviceState>(
                                                  stream: d.state,
                                                  initialData:
                                                      BluetoothDeviceState
                                                          .disconnected,
                                                  builder: (c, snapshot) {
                                                    if (snapshot.data ==
                                                        BluetoothDeviceState
                                                            .connected) {
                                                      return ElevatedButton(
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                                  // background
                                                                  primary: AppColors
                                                                      .aareRiverBrienz,
                                                                  onPrimary:
                                                                      Colors
                                                                          .black),
                                                          child: const Text(
                                                              'START'),
                                                          onPressed: () async {
                                                            _openFlag += 1;
                                                            services = await d
                                                                .discoverServices();
                                                            await readValue(
                                                                services);
                                                          });
                                                    }
                                                    return Text(snapshot.data
                                                        .toString());
                                                  },
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ),
                                StreamBuilder<List<ScanResult>>(
                                  stream: FlutterBluePlus.instance.scanResults,
                                  initialData: const [],
                                  builder: (c, snapshot) => Column(
                                    children: snapshot.data!
                                        .map(
                                          (r) => ScanResultTile(
                                              result: r,
                                              deviceId: deviceName(r.device),
                                              onTap: () async => {
                                                    await r.device.connect(),
                                                    device = r.device,
                                                    _isDisconnectButtonDisabled =
                                                        false,
                                                    setState(() {})
                                                  }),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, 'Cancel');
                            },
                            child: Text(
                              'Cancel',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              FlutterBluePlus.instance.startScan(
                                  timeout: const Duration(seconds: 4));
                            },
                            child: Text(
                              'Search Devices',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ));
          }
        },
      ),
    );
  }

  String deviceName(BluetoothDevice d) {
    for (int i = 0; i < rowsAsListOfValues.length; i++) {
      if (rowsAsListOfValues[i][0] == d.id.toString()) {
        return rowsAsListOfValues[i][1];
      }
    }

    return d.id.toString();
  }

  Future<void> readValue(List<BluetoothService> services) async {
    for (BluetoothService service in services) {
      print(service.uuid.toString().toUpperCase().substring(4, 8));
      if (service.uuid.toString().toUpperCase().substring(4, 8) == "3D86") {
        var characteristics = await service.characteristics;
        for (BluetoothCharacteristic c in characteristics) {
          if (c.uuid.toString().toUpperCase().substring(4, 8) == "6AA8") {
            await c.setNotifyValue(true);
            c.value.listen((value) async {
              String temp = "";
              for (int i = 0; i < value.length; i++) {
                temp += String.fromCharCode(value[i]);
              }

              List data = temp.split(" ");
              accelX = double.parse(data.elementAt(0).toString());
              accelY = double.parse(data.elementAt(1).toString());
              accelZ = double.parse(data.elementAt(2).toString());
              print("AccelX:" +
                  accelX.toString() +
                  "AccelY:" +
                  accelY.toString() +
                  "AccelZ:" +
                  accelZ.toString());
              setState(() {});
            });
          }
          if (c.uuid.toString().toUpperCase().substring(4, 8) == "63D1") {
            await c.setNotifyValue(true);
            c.value.listen((value) async {
              String temp = "";
              for (int i = 0; i < value.length; i++) {
                temp += String.fromCharCode(value[i]);
              }
              List data = temp.split(" ");
              gyroX = double.parse(data.elementAt(0).toString());
              gyroY = double.parse(data.elementAt(1).toString());
              gyroZ = double.parse(data.elementAt(2).toString());
              print("GyroX:" +
                  gyroX.toString() +
                  "GyroY:" +
                  gyroY.toString() +
                  "GyroZ:" +
                  gyroZ.toString());
              setState(() {});
            });
          }
          if (c.uuid.toString().toUpperCase().substring(4, 8) == "333B") {
            await c.setNotifyValue(true);
            c.value.listen((value) async {
              String temp = "";
              for (int i = 0; i < value.length; i++) {
                temp += String.fromCharCode(value[i]);
              }
              print("Heart Rate:" + temp);
              try {
                if (double.parse(temp.substring(0, 5)) > 0 &&
                    double.parse(temp.substring(0, 5)) < 25) {
                  print(double.parse(temp.substring(0, 5)));
                  heartRate += double.parse(temp.substring(0, 5)) * 4;
                  heartRateCounter += 1;
                }
                if (double.parse(temp.substring(0, 5)) > 25 &&
                    double.parse(temp.substring(0, 5)) < 30) {
                  print(double.parse(temp.substring(0, 5)));
                  heartRate += double.parse(temp.substring(0, 5)) * 3;
                  heartRateCounter += 1;
                }
                if (double.parse(temp.substring(0, 5)) > 30 &&
                    double.parse(temp.substring(0, 5)) < 100) {
                  print(double.parse(temp.substring(0, 5)));
                  heartRate += double.parse(temp.substring(0, 5));
                  heartRateCounter += 1;
                }
                if (double.parse(temp.substring(0, 5)) > 100 &&
                    double.parse(temp.substring(0, 5)) < 200) {
                  print(double.parse(temp.substring(0, 5)));
                  heartRate += double.parse(temp.substring(0, 5)) / 2;
                  heartRateCounter += 1;
                }
              } catch (e) {
                print(e);
              }
              if (heartRateCounter == 5) {
                heartRate = heartRate / 5;
                heartRateString = heartRate.toStringAsFixed(1);
                heartRateCounter = 0;
                heartRate = 0;
              }
              setState(() {});
            });
          }
          if (c.uuid.toString().toUpperCase().substring(4, 8) == "A6A0") {
            await c.setNotifyValue(true);
            c.value.listen((value) async {
              String temp = "";
              for (int i = 0; i < value.length; i++) {
                temp += String.fromCharCode(value[i]);
              }

              oxygen = double.parse(temp.toString());
              print("Oxygen:" + oxygen.toString());
              setState(() {});
            });
          }
          if (pullUpFlag) {
            print("Pull Up Flag");
          }
          if (pushUpFlag) {
            print("Push Up Flag");
          }
        }
      }
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/statistics.txt');
  }

  Future<File> writeStatistic(
      String name, int counter, String day, String date) async {
    final file = await _localFile;
    //var sink = file.openWrite(mode: FileMode.append);
    var sink = file.openWrite(mode: FileMode.append);
    sink.writeln('$name, $counter, $day, $date');
    //sink.writeln('$deviceName');
    return file;
  }

  Future<String> readStatistic() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "Read Error!";
    }
  }
  // ...

// ...
}

// convert to integer byte to float

class HeadLine6 extends StatelessWidget {
  const HeadLine6({
    Key? key,
    required this.color,
    required this.text,
    this.fontSize,
  }) : super(key: key);

  final Color color;
  final String? text;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(text!,
        style: GoogleFonts.montserrat(
            textStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  color: color,
                  fontSize: fontSize,
                )));
  }
}

List<String> list = <String>['Which Movement', 'Pull Up', 'Push Up', 'Sit Up'];
List<String> list2 = <String>[
  'Count of Movement',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '10'
];

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({super.key});

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: AppColors.neavyBlue,
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Colors.white),
      underline: Container(
        height: 2,
        color: AppColors.neavyBlue,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          if (dropdownValue == 'Pull Up') {
            pullUpFlag = true;
            pushUpFlag = false;
            sitUpFlag = false;
            audioFlag = true;
            counter = 0;
            name = "pullUp";
          }
          if (dropdownValue == 'Push Up') {
            pushUpFlag = true;
            pullUpFlag = false;
            sitUpFlag = false;
            audioFlag = true;
            counter = 0;
            name = "pushUp";
          }
          if (dropdownValue == 'Sit Up') {
            sitUpFlag = true;
            pullUpFlag = false;
            pushUpFlag = false;
            audioFlag = true;
            counter = 0;
            name = "sitUp";
          }
          if (dropdownValue == 'Which Movement') {
            pullUpFlag = false;
            pushUpFlag = false;
            sitUpFlag = false;
            counter = 0;
          }
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}

class DropdownButtonExample2 extends StatefulWidget {
  const DropdownButtonExample2({super.key});

  @override
  State<DropdownButtonExample2> createState() => _DropdownButtonExampleState2();
}

class _DropdownButtonExampleState2 extends State<DropdownButtonExample2> {
  String dropdownValue = list2.first;
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      dropdownColor: AppColors.neavyBlue,
      value: dropdownValue,
      elevation: 16,
      style: const TextStyle(color: Colors.white),
      underline: Container(
        height: 2,
        color: AppColors.neavyBlue,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          if (dropdownValue != 'Count of Movement') {
            preferredMovement = int.parse(dropdownValue);
          } else {
            preferredMovement = 0;
          }
        });
      },
      items: list2.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
