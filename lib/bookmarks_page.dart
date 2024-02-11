import 'package:flutter/material.dart';
import 'bookmark_manager.dart';

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
                Navigator.of(context).pop("");
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

    if (!context.mounted || folder == null) return;

    if (folder.isEmpty) {
      final m = ScaffoldMessenger.of(context);
      m.clearSnackBars();
      m.showSnackBar(const SnackBar(
        content: Text("No folder name provided"),
      ));
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
    final manager = BookmarkManager.instance;
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
      body: FutureBuilder(
        future: manager.getBookmarkFolders(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: Text("Loading..."));
          }
          final data = snapshot.data!;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (ctx, idx) {
              return Card(
                child: ListTile(
                  title: Text(data[idx].displayName),
                  trailing: Text("$idx"),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
