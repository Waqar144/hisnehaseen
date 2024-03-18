import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'bookmark_manager.dart';
import 'route_handler.dart';
import 'dua.dart';
import 'dua_widget.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<StatefulWidget> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  void _createNewBookmarFolder() async {
    final String? folder = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text("Create New Bookmark Folder"),
          content: TextField(
            decoration: const InputDecoration(hintText: "Folder name..."),
            controller: controller,
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
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );

    if (!mounted || folder == null) return;

    if (folder.isEmpty) {
      final m = ScaffoldMessenger.of(context);
      m.clearSnackBars();
      m.showSnackBar(const SnackBar(
        content: Text("No folder name provided"),
      ));
      return;
    }

    try {
      setState(() {
        BookmarkManager.instance.createNewFolder(folder);
      });
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
    final folders = BookmarkManager.instance.getBookmarkFolders();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add bookmark folder",
            onPressed: _createNewBookmarFolder,
          )
        ],
      ),
      body: ListView.builder(
        itemCount: folders.length,
        itemBuilder: (ctx, idx) {
          return Card(
            child: ListTile(
              title: Text(folders[idx].displayName),
              trailing: Text("${folders[idx].bookmarks.length}"),
              onTap: () {
                Navigator.of(context).pushNamed(
                  Routes.openBookmarkFolder,
                  arguments: folders[idx],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class BookmarkFolderPage extends StatefulWidget {
  final BookmarkFolder folder;

  const BookmarkFolderPage({super.key, required this.folder});

  @override
  State<BookmarkFolderPage> createState() => _BookmarkFolderPageState();
}

class _BookmarkFolderPageState extends State<BookmarkFolderPage> {
  Stream<List<Dua>> _loadFolderDuas() async* {
    Map<int, String> categoryTextCache = {};
    List<Dua> duas = [];
    for (final book in widget.folder.bookmarks) {
      String? text = categoryTextCache[book.categoryIndex];
      text ??=
          await rootBundle.loadString("assets/en/${book.categoryIndex}.txt");
      final textLines = text.split('---').map((s) => s.trim()).toList();
      for (final l in textLines) {
        int? num = Dua.duaNumberFromRaw(l);
        if (num != null && book.duaId == num) {
          duas.add(Dua.fromRaw(l));
          yield duas;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.displayName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: StreamBuilder(
        stream: _loadFolderDuas(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }

          final data = snapshot.data!;

          return ListView.builder(
            key: const PageStorageKey<String>('mylisview'),
            itemCount: data.length,
            itemBuilder: (ctx, index) {
              return DuaWidget.fromDua(data[index]);
            },
          );
        },
      ),
    );
  }
}
