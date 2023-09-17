import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ElectronicDevicesPage(),
    );
  }
}

class ElectronicDevicesPage extends StatefulWidget {
  const ElectronicDevicesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ElectronicDevicesPageState createState() => _ElectronicDevicesPageState();
}

class EditVoltageDialog extends StatefulWidget {
  final String currentVoltage;

  const EditVoltageDialog({super.key, required this.currentVoltage});

  @override
  // ignore: library_private_types_in_public_api
  _EditVoltageDialogState createState() => _EditVoltageDialogState();
}

class _EditVoltageDialogState extends State<EditVoltageDialog> {
  String _tensao = '';

  @override
  void initState() {
    super.initState();
    _tensao = (double.parse(widget.currentVoltage)).round().toString();
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Voltagem', style: Theme.of(context).textTheme.bodyLarge),
      content: DropdownButtonFormField<String>(
        value: _tensao,
        decoration: const InputDecoration(labelText: 'Voltagem'),
        items: ['127', '220'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _tensao = newValue!;
          });
        },
      ),
      actions: [
        TextButton(
          child: Text('Cancelar', style: Theme.of(context).textTheme.bodyLarge),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: Text('Salvar', style: Theme.of(context).textTheme.bodyLarge),
          onPressed: () {
            Navigator.of(context).pop(_tensao);
          },
        ),
      ],
    );
  }
}

class _ElectronicDevicesPageState extends State<ElectronicDevicesPage> {
  List<Map<String, dynamic>> _electronicDevices = [];

  @override
  void initState() {
    super.initState();
    _loadElectronicDevices();
  }
  Future<bool> _requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.status;
    if (status.isGranted) {
      return true;
    } else {
      PermissionStatus newStatus = await Permission.storage.request();
      return newStatus.isGranted;
    }
  }

  Future<void> _loadElectronicDevices() async {
    bool hasPermission = await _requestStoragePermission();
    if (hasPermission) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString('electronic_devices');
      if (jsonString != null) {
        List<dynamic> jsonList = jsonDecode(jsonString);
        _electronicDevices = jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
        setState(() {});
      }
    }
  }


  Future<void> _saveElectronicDevices() async {
    bool hasPermission = await _requestStoragePermission();
    if (hasPermission) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = jsonEncode(_electronicDevices);
      await prefs.setString('electronic_devices', jsonString);
    }
  }

  Future<void> _shareElectronicDevices() async {
    String jsonString = jsonEncode(_electronicDevices);
    await Share.share('Dados dos eletrodomésticos: $jsonString');
  }

  Future<void> _showDeleteConfirmation(int index) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deletar Eletrodoméstico',style: Theme.of(context).textTheme.bodyLarge),
          content: Text('Tem certeza que deseja deletar este eletrodoméstico?',style: Theme.of(context).textTheme.bodyLarge),
          actions: [
            TextButton(
              child: Text('Cancelar',style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Deletar',style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        _electronicDevices.removeAt(index);
      });
      _saveElectronicDevices();
    }
  }

  Future<void> _editElectronicDevice(
      BuildContext context, int index, String nome, double tensao) async {

    String? newTensao = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return EditVoltageDialog(currentVoltage: tensao.toString());
      },
    );


    if (newTensao != null && newTensao != tensao.toString()) {
      setState(() {
        _electronicDevices[index]['tensao'] = double.parse(newTensao);
      });
      _saveElectronicDevices();
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: _electronicDevices.length,
        itemBuilder: (BuildContext context, int index) {
          Map<String, dynamic> device = _electronicDevices[index];
          return ListTile(
            title: Text(device['nome'],style: Theme.of(context).textTheme.bodyLarge),
            subtitle: Text('Voltagem: ${device['tensao']}',style: Theme.of(context).textTheme.bodyLarge),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _editElectronicDevice(
                        context, index, device['nome'], double.parse(device['tensao'].toString()));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    _showDeleteConfirmation(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: FloatingActionButton(
                heroTag: 'share_button',
                onPressed: _shareElectronicDevices,
                child: const Icon(Icons.share),
              ),
            ),
            FloatingActionButton(
              heroTag: 'add_button',
              child: const Icon(Icons.add),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AddElectronicDeviceDialog(
                      onSave: (Map<String, dynamic> newDevice) {
                        setState(() {
                          _electronicDevices.add(newDevice);
                        });
                        _saveElectronicDevices();
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 
 var uuid = Uuid();
 String newDeviceId = uuid.v4();
class AddElectronicDeviceDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  

  const AddElectronicDeviceDialog({required this.onSave});

  @override
  // ignore: library_private_types_in_public_api
  _AddElectronicDeviceDialogState createState() => _AddElectronicDeviceDialogState();
}

class _AddElectronicDeviceDialogState extends State<AddElectronicDeviceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  String _tensao = '127';


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Eletrodoméstico',style: Theme.of(context).textTheme.bodyLarge),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome do Eletrodoméstico'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um nome';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _tensao,
              decoration: const InputDecoration(labelText: 'Voltagem'),
              items: ['127', '220'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _tensao = newValue!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancelar', style: Theme.of(context).textTheme.bodyLarge),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Adicionar', style: Theme.of(context).textTheme.bodyLarge),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'id': newDeviceId,
                'nome': _nomeController.text,
                'tensao': double.parse(_tensao),
                'amperagem': null,
                'potencia': null,
                'ultimamedicao': null,
                'kWh':null,
                'custo':null,
              });

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }
}

