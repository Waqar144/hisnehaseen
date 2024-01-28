import 'package:flutter/material.dart';
import 'categories.dart';
import 'route_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _filterText = ValueNotifier("");
  var _isSearching = false;

  List<String> _filteredCategories() {
    String filterText = _filterText.value.toLowerCase();
    return categories_en
        .where((cat) => cat.toLowerCase().contains(filterText))
        .toList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // BEGIN appbar
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: _isSearching
            ? CloseButton(onPressed: () {
                setState(() {
                  _isSearching = false;
                });
              })
            : null,
        title: _buildAppbarTitleWidget(),
        actions: [
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
          //
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(Routes.settings);
            },
          ),
        ],
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
                  title: Text(cateogries[index]),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(Routes.showCategory, arguments: index);
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
