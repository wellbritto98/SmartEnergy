import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReportPage extends StatefulWidget {
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _collection =
  FirebaseFirestore.instance.collection('electronic_devices');

  String? _selectedDeviceId;
  Map<String, dynamic>? _selectedDeviceData;

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
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                'Selecione o eletrodoméstico que deseja gerar o relatório de consumo:',
                textAlign: TextAlign.center,
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('electronic_devices')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Ocorreu um erro: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                List<DropdownMenuItem<String>> items = snapshot.data!.docs
                    .map<DropdownMenuItem<String>>(
                        (DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                        value: document.id,
                        child: Text((document.data()
                        as Map<String, dynamic>)['nome']),
                      );
                    }).toList();

                return DropdownButton<String>(
                  value: _selectedDeviceId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedDeviceId = newValue;
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
                padding: EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: TextStyle(fontSize: 18),
                primary: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                if (_selectedDeviceId != null) {
                  DocumentSnapshot deviceDoc =
                  await _collection.doc(_selectedDeviceId!).get();
                  Map<String, dynamic> deviceData =
                  deviceDoc.data() as Map<String, dynamic>;

                  setState(() {
                    _selectedDeviceData = deviceData;
                  });
                }
              },
            ),
          ],
        )
            : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        Text('Nome: ${_selectedDeviceData!['nome']}'),
        Text('Voltagem: ${_selectedDeviceData!['tensao']}'),
        Text('Amperagem: ${_selectedDeviceData!['amperagem'] ?? '-'}'),
        Text('Potência: ${_selectedDeviceData!['potencia'] ?? '-'}'),
        ElevatedButton(
        child: Text('Exportar em PDF'),
    onPressed: () async {
    final pdf = await _generatePdf();
    await Printing.sharePdf(
    bytes: await pdf.save(),
      filename: 'relatorio_${_selectedDeviceData!['nome']}.pdf',
    );
    },
        ),
            ],
        ),
    );
  }
}

