import 'package:flutter/material.dart';

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
      final first = Text(firstLine.substring(s + 1));
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

class DuaWidget extends StatelessWidget {
  final String _duaText;
  const DuaWidget(this._duaText, {super.key});

  @override
  Widget build(BuildContext context) {
    String? num;
    int s = _duaText.indexOf(':');
    if (s != -1) num = _duaText.substring(0, s);

    return Card(
      child: ListTile(
        title: Column(
          children: [
            Row(
              children: [
                if (num != null)
                  CircleAvatar(
                    radius: 16,
                    child: Text(num),
                  ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark),
                  onPressed: () {},
                ),
              ],
            ),
            TextWidget(_duaText),
          ],
        ),
      ),
    );
  }
}
