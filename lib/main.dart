import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  runApp(MaterialApp(
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Database? db;
  List<String> imcs = [];

  TextEditingController pesoController = TextEditingController();
  TextEditingController alturaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    iniciarBancoDeDados();
  }

  Future<void> iniciarBancoDeDados() async {
    db = await openDatabase(
      join(await getDatabasesPath(), 'imc.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE imcs(id INTEGER PRIMARY KEY, imc TEXT)",
        );
      },
      version: 1,
    );
    atualizarLista();
  }

  Future<void> inserir(String imc) async {
    await db!.insert(
      'imcs',
      {'imc': imc},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    atualizarLista();
  }

  Future<void> atualizarLista() async {
    final List<Map<String, dynamic>> maps = await db!.query('imcs');
    setState(() {
      imcs = List.generate(maps.length, (i) => maps[i]['imc'].toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora de IMC'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: pesoController,
              decoration: InputDecoration(
                labelText: 'Peso (kg)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: alturaController,
              decoration: InputDecoration(
                labelText: 'Altura (m)',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              child: Text('Calcular IMC'),
              onPressed: () {
                double peso = double.parse(pesoController.text);
                double altura = double.parse(alturaController.text);
                if (altura != 0) {
                  double imc = peso / (altura * altura);
                  inserir(imc.toStringAsFixed(2));
                } else {
                  print('Altura não pode ser zero.');
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: imcs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('IMC: ${imcs[index]}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
