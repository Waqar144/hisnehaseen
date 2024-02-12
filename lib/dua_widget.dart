import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart' show Clipboard, ClipboardData;

import 'dua.dart';
import 'bookmark_manager.dart';

class _BookmarkDialog extends StatefulWidget {
  final List<BookmarkFolder> folders;

  const _BookmarkDialog({required this.folders});
  @override
  State<_BookmarkDialog> createState() => _BookmarkDialogState();
}

class _BookmarkDialogState extends State<_BookmarkDialog> {
  BookmarkFolder? selected;

  @override
  Widget build(BuildContext context) {
    selected ??= widget.folders.first; // preselect first if nothing selected
    return AlertDialog(
      title: const Text("Create Bookmark"),
      content: Row(
        children: [
          const Text("Folder"),
          const SizedBox(width: 8),
          DropdownButton(
            onChanged: (s) {
              if (s != null) {
                setState(() {
                  selected = s;
                });
              }
            },
            value: selected,
            items: widget.folders
                .map(
                  (f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.displayName),
                  ),
                )
                .toList(),
          )
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
        TextButton(
          child: const Text("Create"),
          onPressed: () {
            Navigator.of(context).pop(selected);
          },
        ),
      ],
    );
  }
}

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
  final void Function(bool) onBookmarkPressed;
  final bool isDuaBookmarked;

  const _DuaHeader({
    required this.num,
    required this.onSharePressed,
    required this.onBookmarkPressed,
    required this.isDuaBookmarked,
  });

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
          icon: isDuaBookmarked
              ? const Icon(Icons.bookmark)
              : const Icon(Icons.bookmark_outline),
          onPressed: () => onBookmarkPressed(isDuaBookmarked),
        ),
      ],
    );
  }
}

class DuaWidget extends StatefulWidget {
  /// The chapter containing this dua
  final int categoryIndex;
  final Dua _dua;
  DuaWidget(this.categoryIndex, String duaText, {super.key})
      : _dua = Dua.fromRaw(duaText);

  const DuaWidget.fromDua(this._dua, {super.key}) : categoryIndex = -1;

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

  void _bookmarkDua(bool alreadyBookmarked) async {
    if (alreadyBookmarked) {
      BookmarkManager.instance
          .removeBookmark(widget.categoryIndex, widget._dua.num!);
      return;
    }

    final folders = BookmarkManager.instance.getBookmarkFolders();
    if (!mounted) return;

    final selected = await showDialog<BookmarkFolder>(
      context: context,
      builder: (ctx) {
        // ignore: prefer_const_constructors
        return _BookmarkDialog(folders: folders);
      },
    );

    if (selected == null || !mounted) return;

    try {
      BookmarkManager.instance
          .bookmarkDua(selected, widget.categoryIndex, widget._dua.num!);
    } catch (e) {
      final m = ScaffoldMessenger.of(context);
      m.clearSnackBars();
      m.showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Error: $e"),
      ));
    }
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
              isDuaBookmarked: BookmarkManager.instance
                  .isDuaBookmarked(widget.categoryIndex, num),
            ),
            _DuaBody(widget._dua),
          ],
        ),
      ),
    );
  }
}
