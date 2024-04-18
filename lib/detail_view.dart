import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'categories.dart';
import 'dua_widget.dart';

class DetailsView extends StatefulWidget {
  final int categoryIndex;
  const DetailsView(this.categoryIndex, {super.key});

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  late List<String> textLines;

  @override
  void initState() {
    super.initState();
  }

  Future<List<String>> _load() async {
    final text =
        await rootBundle.loadString("assets/en/${widget.categoryIndex}.txt");
    textLines = text.split('---').map((s) => s.trim()).toList();
    return textLines;
  }

  String _categoryTitle() {
    return categories_en[widget.categoryIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _categoryTitle(),
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        titleSpacing: 0,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        shadowColor: Theme.of(context).colorScheme.shadow,
      ),
      body: FutureBuilder(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: Text("Loading..."));
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          return ListView.builder(
            key: const PageStorageKey<String>('mylisview'),
            itemCount: textLines.length,
            itemBuilder: (ctx, index) {
              final line = textLines[index];
              return DuaWidget(widget.categoryIndex, line);
            },
          );
        },
      ),
    );
  }
}
