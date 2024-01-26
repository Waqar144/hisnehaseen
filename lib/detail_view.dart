import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'categories.dart';

String _superScriptForNum(int n) {
  return switch (n) {
    1 => '\u00b9',
    2 => '\u00b2',
    3 => '\u00b3',
    _ => throw "Missing superscript conversion for $n",
  };
}

String _lineEndsWithRefNumber(String line) {
  int open = line.lastIndexOf("[");
  if (open == -1) {
    // ignore: avoid_print
    print("Unexpected, didn't find open bracket!!");
    return line;
  }
  String num = line.substring(open + 1, line.length - 1);
  int? n = int.tryParse(num);
  if (n == null) {
    return line;
  }
  num = _superScriptForNum(n);
  return line.replaceRange(open, null, num);
}

class TextWidget extends StatelessWidget {
  final String text;
  const TextWidget(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    List<String> lines = text.split('\n');
    TextDirection dir = TextDirection.ltr;
    List<Widget> children = [];

    String firstLine = lines.first;
    int s = firstLine.indexOf(':');
    String num = "";
    if (s != -1) num = firstLine.substring(0, s);

    if (firstLine.endsWith("]")) {
      firstLine = _lineEndsWithRefNumber(firstLine);
    }

    List<String> refs = [];

    if (int.tryParse(num) != null) {
      final first = Text.rich(
        TextSpan(children: [
          WidgetSpan(
            child: CircleAvatar(
              radius: 16,
              child: Text(num),
            ),
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
          ),
          TextSpan(text: firstLine.substring(s + 1)),
        ]),
      );
      children.add(first);
      lines.removeAt(0);
    }

    for (String line in lines) {
      if (line.startsWith('ar:')) {
        children.add(Text(
          line.substring(3),
          textAlign: TextAlign.start,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontFamily: "IndoPak",
            fontSize: 28,
            letterSpacing: 0,
          ),
        ));
        continue;
      }

      if (line.endsWith("]")) {
        line = _lineEndsWithRefNumber(line);
      }

      if (line.startsWith('ref:')) {
        refs.add(line.substring(4));
        continue;
      }

      children.add(Text(
        line,
        textDirection: dir,
        textAlign: TextAlign.start,
      ));
    }

    // Add references
    if (refs.isNotEmpty) {
      children.add(const Divider(height: 1));
    }
    for (final ref in refs) {
      children.add(Text(
        ref,
        style: Theme.of(context).textTheme.bodySmall,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

class DetailsView extends StatefulWidget {
  final int categoryIndex;
  const DetailsView(this.categoryIndex, {super.key});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  late List<String> textLines;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _load() async {
    final text =
        await rootBundle.loadString("assets/en/${widget.categoryIndex}.txt");
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
            key: const PageStorageKey<String>('mylisview'),
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
