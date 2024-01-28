import 'package:flutter/material.dart';

import 'dua.dart';

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
  final Dua _dua;
  const TextWidget(this._dua, {super.key});

  @override
  Widget build(BuildContext context) {
    TextDirection dir = TextDirection.ltr;
    List<Widget> children = [];

    for (final line in _dua.body) {
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

      children.add(Text(
        line,
        textDirection: dir,
        textAlign: TextAlign.start,
      ));
    }

    // Add references
    if (_dua.refs.isNotEmpty) {
      children.add(const Divider(height: 1));
    }
    for (final ref in _dua.refs) {
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
  final Dua _dua;
  DuaWidget(String duaText, {super.key}) : _dua = Dua.fromRaw(duaText);

  @override
  Widget build(BuildContext context) {
    String? num = _dua.num;
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
            TextWidget(_dua),
          ],
        ),
      ),
    );
  }
}
