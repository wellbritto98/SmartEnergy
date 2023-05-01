import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ElectronicDevicesPage extends StatefulWidget {
  @override
  _ElectronicDevicesPageState createState() => _ElectronicDevicesPageState();
}

class EditVoltageDialog extends StatefulWidget {
  final String currentVoltage;

  EditVoltageDialog({required this.currentVoltage});

  @override
  _EditVoltageDialogState createState() => _EditVoltageDialogState();
}

class _EditVoltageDialogState extends State<EditVoltageDialog> {
  String _tensao = '';

  @override
  void initState() {
    super.initState();
    _tensao = widget.currentVoltage;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Editar Voltagem'),
      content: DropdownButtonFormField<String>(
        value: _tensao,
        decoration: InputDecoration(labelText: 'Voltagem'),
        items: ['110', '220'].map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
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
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: Text('Salvar'),
          onPressed: () {
            Navigator.of(context).pop(_tensao);
          },
        ),
      ],
    );
  }
}

class _ElectronicDevicesPageState extends State<ElectronicDevicesPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('electronic_devices');


  Future<void> _showDeleteConfirmation(String docId) async {
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Deletar Eletrodoméstico'),
          content: Text('Tem certeza que deseja deletar este eletrodoméstico?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('Deletar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteElectronicDevice(docId);
    }
  }
  Future<void> _deleteElectronicDevice(String docId) async {
    await _collection.doc(docId).delete();
  }

  Future<void> _editElectronicDevice(
      BuildContext context, String docId, String nome, String tensao) async {
    String? newTensao = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return EditVoltageDialog(currentVoltage: tensao);
      },
    );

    if (newTensao != null && newTensao != tensao) {
      await _collection.doc(docId).update({'tensao': newTensao});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _collection.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Ocorreu um erro: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Carregando...');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
              document.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['nome']),
                subtitle: Text('Voltagem: ${data['tensao']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editElectronicDevice(
                            context, document.id, data['nome'], data['tensao']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showDeleteConfirmation(document.id);
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddElectronicDeviceDialog();
            },
          );
        },
      ),
    );
  }
}

class AddElectronicDeviceDialog extends StatefulWidget {
  @override
  _AddElectronicDeviceDialogState createState() => _AddElectronicDeviceDialogState();
}

class _AddElectronicDeviceDialogState extends State<AddElectronicDeviceDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  String _tensao = '110';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adicionar Eletrodoméstico'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: InputDecoration(labelText: 'Nome do Eletrodoméstico'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira um nome';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _tensao,
              decoration: InputDecoration(labelText: 'Voltagem'),
              items: ['110', '220'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
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
          child: Text('Cancelar'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Adicionar'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await FirebaseFirestore.instance.collection('electronic_devices').add({
                'nome': _nomeController.text,
                'tensao': _tensao,
                'amperagem': null,
                'potencia': null,
                'ultimamedicao': null,
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

