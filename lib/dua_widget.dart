import 'package:flutter/material.dart';

import 'dua.dart';

class _DuaBody extends StatelessWidget {
  final Dua _dua;
  const _DuaBody(this._dua);

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

class _DuaHeader extends StatelessWidget {
  final String? num;
  final VoidCallback onSharePressed;
  final VoidCallback onBookmarkPressed;

  const _DuaHeader(
      {required this.num,
      required this.onSharePressed,
      required this.onBookmarkPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (num != null)
          CircleAvatar(
            radius: 16,
            child: Text(num!),
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
    );
  }
}

class DuaWidget extends StatelessWidget {
  final Dua _dua;
  DuaWidget(String duaText, {super.key}) : _dua = Dua.fromRaw(duaText);

  void _shareDua() {}

  void _bookmarkDua() {}

  @override
  Widget build(BuildContext context) {
    String? num = _dua.num;
    return Card(
      child: ListTile(
        title: Column(
          children: [
            _DuaHeader(
                num: num,
                onSharePressed: _shareDua,
                onBookmarkPressed: _bookmarkDua),
            _DuaBody(_dua),
          ],
        ),
      ),
    );
  }
}
