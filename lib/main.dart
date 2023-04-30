import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_core/core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'electronic_devices_page.dart';




void main() async{
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}


class MeasurementPage extends StatefulWidget {
  @override
  _MeasurementPageState createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> {
  bool _showIcon = true;
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _showIcon
          ? IconButton(
              icon: Icon(Icons.power_settings_new, size: 50),
              onPressed: () {
                setState(() {
                  _showIcon = false;
                  _counter = 123; // Exemplo de valor do contador
                });
              },
            )
          : Text(
              'Contador: $_counter',
              style: TextStyle(fontSize: 24),
            ),
    );
  }
}




class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
final List<Widget> _pages = [
  MeasurementPage(),
  ElectronicDevicesPage(),
  const Text("Relatórios"),
];


  final List<String> _titles = [
    "Medição de energia",
    "Eletrodomésticos",
    "Relatórios",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
      ),
      body: Center(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.bolt),
            label: 'Medição',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.plug),
            label: 'Eletrodomésticos',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartBar),
            label: 'Relatórios',
          ),
        ],
      ),
    );
  }
}
