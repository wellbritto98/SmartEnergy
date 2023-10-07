import 'dart:io';

import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'electronic_devices_page.dart';
import 'dart:ui';
import 'report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:udp/udp.dart';
import 'package:flutter/services.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  serverIp = prefs.getString('server_ip') ?? '000.000.0.00';

  runApp(MyApp());
}


String serverIp = '000.000.0.00';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: customThemeData,
      child: MaterialApp(
        title: 'Eletrodomésticos',
        theme: customThemeData,
        home: MyHomePage(),
      ),
    );
  }
}


final ThemeData customThemeData = ThemeData(
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
    displaySmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black),
  ),
);

class Device {
  final String nome;
  final double tensao;
  final double amperagem;
  final double potencia;
  final String ultimamedicao;
  final double kWh;
  final double custo;

  Device({
    required this.nome,
    required this.tensao,
    required this.amperagem,
    required this.potencia,
    required this.ultimamedicao,
    required this.kWh,
    required this.custo,
  });



  factory Device.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic value) {
    if (value is String && value.toLowerCase() == 'nan') {
      return null;
    }
    return (value is String) ? double.tryParse(value) : value?.toDouble();
  }
    return Device(
      nome: json['nome'] ?? '',
      tensao: parseDouble(json['tensao']) ?? 0,
      amperagem: parseDouble(json['amperagem']) ?? 0,
      potencia: parseDouble(json['potencia']) ?? 0,
      ultimamedicao: json['ultimamedicao']?.toString() ?? '',
      kWh: parseDouble(json['kWh']) ?? 0,
      custo: parseDouble(json['custo']) ?? 0,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'tensao': tensao,
      'amperagem': amperagem,
      'potencia': potencia,
      'ultimamedicao': ultimamedicao,
      'kWh': kWh, // Adicione esta linha
      'custo': custo, // Adicione esta linha
    };
  }
} 


  class _ServerIpDialog extends StatefulWidget {
    
    final String serverIp;

    _ServerIpDialog({required this.serverIp});

    @override
    _ServerIpDialogState createState() => _ServerIpDialogState();
  }

  class _ServerIpDialogState extends State<_ServerIpDialog> {
    late TextEditingController _controller;

    @override
    void initState() {
      super.initState();
      _controller = TextEditingController(text: widget.serverIp);
    }

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: const Text('Insira o endereço IP do servidor'),
        content: TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Salvar'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      );
    }
  }


Future<void> saveMeasurementState(bool isMeasuring) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('is_measuring', isMeasuring);
}

Future<bool> getMeasurementState() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('is_measuring') ?? false;
}

Future<void> updateDeviceInfo(Device updatedDevice) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String devicesJson = prefs.getString('electronic_devices') ?? '[]';
  List<dynamic> decodedJson = json.decode(devicesJson);
  List<Device> devices = decodedJson.map((deviceJson) => Device.fromJson(deviceJson)).toList();

  int index = devices.indexWhere((device) => device.nome == updatedDevice.nome);
  if (index != -1) {
    devices[index] = updatedDevice;
    prefs.setString('electronic_devices', json.encode(devices.map((device) => device.toJson()).toList()));
  }
}



class MeasurementPage extends StatefulWidget {
  const MeasurementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MeasurementPageState createState() => _MeasurementPageState();
}

class _MeasurementPageState extends State<MeasurementPage> with TickerProviderStateMixin {
  List<Device> _deviceObjects = [];
  Device? _selectedDevice;
  final List<String> _devices = [];
  bool _isMeasuring = false;
  final double _counter = 0.0;
  late AnimationController _animationController;

  @override
    void initState() {
      super.initState();
      _loadDevices();
      _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: 1),
      );
      _animationController.repeat();
      _checkMeasurementState();
    }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!_isMeasuring)
          DropdownButton<Device>(
            value: _selectedDevice,
            hint: Text('Selecione um eletrodoméstico', style: Theme.of(context).textTheme.bodyLarge),
            onChanged: (Device? newValue) {
              setState(() {
                _selectedDevice = newValue;
              });
            },
            items: _deviceObjects.map<DropdownMenuItem<Device>>((Device value) {
              return DropdownMenuItem<Device>(
                value: value,
                child: Text(value.nome, style: Theme.of(context).textTheme.bodyLarge),
              );
            }).toList(),
          ),
        if (!_isMeasuring)
          ElevatedButton.icon(
            onPressed: _startMeasurement,
            icon: const Icon(Icons.timer),
            label: const Text('Iniciar medição'),
          ),
        if (_isMeasuring) const CircularProgressIndicator(),
        if (_isMeasuring)
          Text(
            'Medição em andamento',
             style: Theme.of(context).textTheme.displayLarge,
          ),
        if (_isMeasuring)
          ElevatedButton(
            onPressed: _stopMeasurement,
            child: Text('Finalizar medição', style: Theme.of(context).textTheme.bodyLarge),
          ),
      ],
    ),
  );
}
  void _checkMeasurementState() async {
    bool isMeasuring = await getMeasurementState();
    setState(() {
      _isMeasuring = isMeasuring;
    });
  }
Future<void> _startMeasurement() async {
  if (_selectedDevice != null) {
    final response = await http.get(
      Uri.parse('http://$serverIp/start_measurement?device_name=${_selectedDevice!.nome}&tension=${_selectedDevice!.tensao}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isMeasuring = true;
      });
      await saveMeasurementState(_isMeasuring);
    } else {
      throw Exception('Failed to start measurement');
    }
  }
}


Future<void> _stopMeasurement() async {
  final response = await http.get(Uri.parse('http://$serverIp/stop_measurement'));

  if (response.statusCode == 200) {
    Device updatedDevice = Device.fromJson(json.decode(response.body));
    await updateDeviceInfo(updatedDevice);

    setState(() {
      _isMeasuring = false;
      // Atualize o contador e outros dados aqui
      // Por exemplo: _counter = double.parse(response.body);,
    });
    await saveMeasurementState(_isMeasuring);
  } else {
    throw Exception('Failed to stop measurement');
  }
}



  void _loadDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String devicesJson = prefs.getString('electronic_devices') ?? '[]';
    List<dynamic> decodedJson = json.decode(devicesJson);
    List<Device> devices = decodedJson.map((deviceJson) => Device.fromJson(deviceJson)).toList();

    setState(() {
      _deviceObjects = devices;
      _selectedDevice = devices.isNotEmpty ? devices[0] : null;
    });
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
    ReportPage(),
  ];
  String serverIp = '000.000.0.00';
  static const platform = const MethodChannel('samples.flutter.dev/udp');

// Cria uma função para chamar o método nativo
void _receiveBroadcast() async {
  print('Calling getBroadcastMessage method');
  try {
    final String result = await platform.invokeMethod('getBroadcastMessage');
    print('Received: $result');
    if (result.startsWith('NodeMCU_IP:')) {
      var ip = result.substring('NodeMCU_IP:'.length);
      print('NodeMCU IP: $ip');
      setState(() {
        serverIp = ip;
      });
      _showConfirmationDialog('Conectado ao medidor. IP: $serverIp');
    }
  } on PlatformException catch (e) {
    print("Failed to receive broadcast: '${e.message}'.");
  }
}

  Future<void> _showConfirmationDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmação'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

Future<void> _showServerIpDialog() async {
  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Conectar ao Medidor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Aperte o botão presente no medidor, quando o led amarelo acender, solte o botão e clique em \"Iniciar conexão\" abaixo",
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _receiveBroadcast();
                Navigator.of(context).pop();
              },
              child: Text("Iniciar Conexão"),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}




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
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.wifi),
          onPressed: _showServerIpDialog,
        ),
      ],
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

