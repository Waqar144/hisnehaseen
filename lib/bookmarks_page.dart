import 'package:flutter/material.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<StatefulWidget> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shadowColor: Theme.of(context).colorScheme.shadow,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add bookmark folder",
            onPressed: () {},
          )
        ],
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (ctx, idx) {
          return Card(
            child: ListTile(
              title: Text("Dummy $idx"),
              trailing: Text("$idx"),
            ),
          );
        },
      ),
    );
  }
}
