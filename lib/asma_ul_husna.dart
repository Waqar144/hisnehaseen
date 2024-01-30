import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AsmaulHusna extends StatefulWidget {
  const AsmaulHusna({super.key});

  @override
  State<AsmaulHusna> createState() => _AsmaulHusnaState();
}

class _AsmaulHusnaState extends State<AsmaulHusna> {
  late final List<String> textLines;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _load() async {
    final text = await rootBundle.loadString("assets/en/9.txt");
    textLines = text.split('\n').map((s) => s.trim()).toList();
    return textLines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asma ul Husna'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: Text("Loading..."));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3),
            itemCount: 99,
            itemBuilder: (ctx, idx) {
              String line = textLines[idx];
              final parts = line.split('\t');
              String arWord = parts[1].trim();
              String meaning = parts[3].trim();

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      arWord,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "IndoPak",
                        fontSize: 20,
                        letterSpacing: 0,
                      ),
                    ),
                    Text(meaning, textAlign: TextAlign.center),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
