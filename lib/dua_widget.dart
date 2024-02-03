import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

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
            height: 1.8,
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
  final String num;
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
        CircleAvatar(
          radius: 16,
          child: Text(num),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: onSharePressed,
        ),
        IconButton(
          icon: const Icon(Icons.bookmark),
          onPressed: onBookmarkPressed,
        ),
      ],
    );
  }
}

class DuaWidget extends StatefulWidget {
  final Dua _dua;
  DuaWidget(String duaText, {super.key}) : _dua = Dua.fromRaw(duaText);

  @override
  State<DuaWidget> createState() => _DuaWidgetState();
}

class _DuaWidgetState extends State<DuaWidget> {
  void _shareDua() {
    // On desktop just copy to clipboard
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      Clipboard.setData(ClipboardData(text: widget._dua.shareableText()));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Durations.extralong1,
      ));
      return;
    }

    final box = context.findRenderObject() as RenderBox?;

    Share.share(
      widget._dua.shareableText(),
      subject: "",
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  void _bookmarkDua() async {
    await showDialog(
        context: context,
        builder: (ctx) {
          // ignore: prefer_const_constructors
          return AlertDialog(
            title: const Text("Create Bookmark"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Folder"),
                DropdownButton(
                  onChanged: (s) {},
                  items: ["First", "Second", "Third"].map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    String? num = widget._dua.num;
    // If there is no number then show simple text
    if (num == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(widget._dua.body.join("\n")),
      );
    }

    return Card(
      child: ListTile(
        title: Column(
          children: [
            _DuaHeader(
              num: num,
              onSharePressed: _shareDua,
              onBookmarkPressed: _bookmarkDua,
            ),
            _DuaBody(widget._dua),
          ],
        ),
      ),
    );
  }
}
