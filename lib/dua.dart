class Dua {
  final String? num;
  final List<String> body;
  final List<String> refs;

  const Dua({
    required this.num,
    required this.body,
    required this.refs,
  });

  static int? duaNumberFromRaw(String raw) {
    int s = raw.indexOf(':');
    if (s > 10) {
      print("Bad dua text? $raw");
      return null;
    }
    if (s != -1) {
      String num = raw.substring(0, s);
      return int.tryParse(num);
    } else {
      return null;
    }
  }

  factory Dua.fromRaw(String raw) {
    List<String> lines = raw.split('\n');

    String firstLine = lines.first;
    int s = firstLine.indexOf(':');
    String? num;
    if (s != -1) num = firstLine.substring(0, s);

    if (firstLine.endsWith("]")) {
      firstLine = _lineEndsWithRefNumber(firstLine);
    }

    List<String> refs = [];
    List<String> body = [];

    if (num != null && int.tryParse(num) != null) {
      lines.removeAt(0);
      final l = firstLine.substring(s + 1).trim();
      if (l.isNotEmpty) {
        body.add(l);
      }
    } else {
      num = null;
    }

    for (String line in lines) {
      // footnote at end?
      if (line.endsWith("]")) {
        line = _lineEndsWithRefNumber(line);
        body.add(line);
        continue;
      }

      // ref?
      if (line.startsWith('ref:')) {
        refs.add(line.substring(4));
        continue;
      }

      body.add(line);
      continue;
    }

    return Dua(num: num, body: body, refs: refs);
  }

  String shareableText() {
    String ret = "";
    for (final line in body) {
      ret += "$line\n";
    }

    for (final ref in refs) {
      ret += "$ref\n";
    }
    return ret;
  }
}

String _superScriptForNum(int n) {
  return switch (n) {
    1 => '\u00b9',
    2 => '\u00b2',
    3 => '\u00b3',
    4 => '\u2074',
    5 => '\u2075',
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
