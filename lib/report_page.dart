import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  int? _selectedDeviceIndex;
  Map<String, dynamic>? _selectedDeviceData;

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/devices.json');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<List<Map<String, dynamic>>> readDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('electronic_devices');
    if (jsonString != null) {
      List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => Map<String, dynamic>.from(e)).toList();
    } else {
      return [];
    }
  }

  Future<pw.Document> _generatePdf() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Nome: ${_selectedDeviceData!['nome']}'),
              pw.Text('Voltagem: ${_selectedDeviceData!['tensao']}'),
              pw.Text('Amperagem: ${_selectedDeviceData!['amperagem'] ?? '-'}'),
              pw.Text('Potência: ${_selectedDeviceData!['potencia'] ?? '-'}'),
              pw.Text('kWh: ${_selectedDeviceData!['kWh'] ?? '-'}'),
              pw.Text('Custo: ${_selectedDeviceData!['custo'] ?? '-'}'),
            ],
          );
        },
      ),
    );
    return pdf;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _selectedDeviceData == null
          ? SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: const Text(
                      'Selecione o eletrodoméstico que deseja gerar o relatório de consumo:',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: readDevices(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                      if (snapshot.hasError) {
                        return Text('Ocorreu um erro: ${snapshot.error}');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      List<DropdownMenuItem<int>> items = List<DropdownMenuItem<int>>.generate(
                        snapshot.data!.length,
                        (index) {
                          Map<String, dynamic> device = snapshot.data![index];
                          return DropdownMenuItem<int>(
                            value: index,
                            child: Text(device['nome']),
                          );
                        },
                      );

                      return DropdownButton<int>(
                        value: _selectedDeviceIndex,
                        onChanged: (int? newValue) {
                          setState(() {
                            _selectedDeviceIndex = newValue;
                          });
                        },
                        items: items,
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    child: Text('Gerar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(fontSize: 18),
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      if (_selectedDeviceIndex != null) {
                        List<Map<String, dynamic>> devices = await readDevices();
                        Map<String, dynamic> deviceData = devices[_selectedDeviceIndex!];

                        setState(() {
                          _selectedDeviceData = deviceData;
                        });
                      }
                    },
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nome: ${_selectedDeviceData!['nome']}',
                  ),
                  Text(
                    'Voltagem: ${_selectedDeviceData!['tensao']}V',
                  ),
                  Text(
                    'Amperagem: ${_selectedDeviceData!['amperagem'] ?? '-'}A',
                  ),
                  Text(
                    'Potência: ${_selectedDeviceData!['potencia'] ?? '-'}W',
                  ),
                  Text(
                    'kWh: ${_selectedDeviceData!['kWh'] ?? '-'}kWh',
                  ),
                  Text(
                    'Custo: ${_selectedDeviceData!['custo'] ?? '-'}reais',
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(
                        inherit: true, // define a propriedade "inherit"
                        // adicione outras propriedades do TextStyle, se necessário
                      ),
                    ),
                    onPressed: () async {
                      final pdf = await _generatePdf();
                      await Printing.sharePdf(
                        bytes: await pdf.save(),
                        filename: 'relatorio_${_selectedDeviceData!['nome']}.pdf',
                      );
                    },
                    child: const Text('Exportar em PDF'),
                  ),
                ],
              ),
            ),
    );
  }
}


