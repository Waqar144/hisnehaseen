import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TextWidget extends StatelessWidget {
  final String text;
  const TextWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split('\n');
    TextDirection dir = TextDirection.ltr;
    List<Widget> children = [];
    for (final line in lines) {
      if (line.startsWith('ar:')) {
        children.add(Text(
          line.substring(3),
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: "IndoPak",
            fontSize: 28,
            letterSpacing: 0,
          ),
        ));
        continue;
      }
      children.add(Text(
        line,
        textDirection: dir,
        textAlign: TextAlign.start,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class DetailsView extends StatefulWidget {
  const DetailsView({super.key});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  late final List<String> textLines;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _load() async {
    final text = await rootBundle.loadString("assets/en/0.txt");
    textLines = text.split('---').map((s) => s.trim()).toList();
    return textLines;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          return ListView.builder(
            itemCount: textLines.length,
            itemBuilder: (ctx, index) {
              return Card(
                child: ListTile(
                  title: TextWidget(textLines[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
