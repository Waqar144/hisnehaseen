import 'package:flutter/material.dart';
import 'categories.dart';
import 'route_handler.dart';
import 'bookmark_manager.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _filterText = ValueNotifier("");
  var _isSearching = false;

  @override
  void initState() {
    super.initState();

    BookmarkManager.instance.init();
  }

  List<({int idx, String name})> _filteredCategories() {
    String filterText = _filterText.value.toLowerCase();
    return allCategories()
        .indexed
        .where((cat) => cat.$2.toLowerCase().contains(filterText))
        .map((e) => (idx: e.$1, name: e.$2))
        .toList();
  }

  List<String> allCategories() {
    return categories_en;
  }

  Widget _buildAppbarTitleWidget() {
    if (!_isSearching) {
      return Text(widget.title);
    }
    return TextField(
      autofocus: true,
      decoration: const InputDecoration(
        hintText: "Filter...",
        border: InputBorder.none,
      ),
      onChanged: (query) => _filterText.value = query,
    );
  }

  List<Widget> _appbarActions() {
    if (_isSearching) {
      return [];
    }

    return [
      // Search button
      if (_isSearching == false)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
      // Bookmarks Button
      IconButton(
        icon: const Icon(Icons.bookmark),
        tooltip: "Bookmarks",
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.bookmarks);
        },
      ),
      // Settings Button
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.settings);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BEGIN appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _isSearching
            ? CloseButton(onPressed: () {
                setState(() {
                  _filterText.value = "";
                  _isSearching = false;
                });
              })
            : null,
        title: _buildAppbarTitleWidget(),
        actions: _appbarActions(),
      ), // END appbar
      body: ValueListenableBuilder(
        valueListenable: _filterText,
        builder: (context, value, _) {
          final cateogries = _filteredCategories();
          return ListView.builder(
            itemCount: cateogries.length,
            itemBuilder: (ctx, index) {
              return Card(
                child: ListTile(
                  title: Text(cateogries[index].name),
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.showCategory,
                        arguments: cateogries[index].idx);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
