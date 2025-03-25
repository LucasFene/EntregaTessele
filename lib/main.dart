import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzasyBWZ8jQIrcAdqsdQLm6SvcKJccCRswwK_MT",
        appId: "1:443352041625:android:C5fc6c887d88651e2fd008",
        messagingSenderId: "443352041625",
        projectId: "conexao-firebase-82c8d",
      ),
    );
    print("Firebase Inicializado com sucesso!");
  } catch (e) {
    print("Erro ao inicializar o Firebase: $e");
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sorteio de Nomes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SorteioScreen(),
    );
  }
}

class SorteioScreen extends StatefulWidget {
  @override
  _SorteioScreenState createState() => _SorteioScreenState();
}

class _SorteioScreenState extends State<SorteioScreen> {
  List<String> nomes = ['Alice', 'Bob', 'Charlie', 'David', 'Eva'];
  String nomeSorteado = '';
  List<String> nomesSalvos = [];

  Future<void> salvarNome(String nome) async {
    try {
      await FirebaseFirestore.instance.collection('nomesSorteados').add({
        'nome': nome,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print("Nome salvo com sucesso!");
    } catch (e) {
      print("Erro ao salvar nome no Firestore: $e");
    }
  }

  Future<void> carregarNomesSalvos() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('nomesSorteados').get();
      setState(() {
        nomesSalvos = querySnapshot.docs.map((doc) => doc['nome'] as String).toList();
      });
      print("Conexão com Firestore bem-sucedida!");
    } catch (e) {
      print("Erro ao carregar dados do Firestore: $e");
    }
  }

  void sortearNome() {
    setState(() {
      nomeSorteado = nomes[(nomes.length * DateTime.now().millisecond / 1000).floor()];
    });
  }

  @override
  void initState() {
    super.initState();
    carregarNomesSalvos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sorteio de Nomes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                sortearNome();
              },
              child: Text('Sortear Nome'),
            ),
            SizedBox(height: 20),
            Text('Nome Sorteado: $nomeSorteado', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (nomeSorteado.isNotEmpty) {
                  salvarNome(nomeSorteado);
                  carregarNomesSalvos();
                }
              },
              child: Text('Salvar Nome'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: nomesSalvos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(nomesSalvos[index]),
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
