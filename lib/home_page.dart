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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: categories_en.length,
        itemBuilder: (ctx, index) {
          return Card(
            child: ListTile(
              title: Text(categories_en[index]),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(Routes.showCategory, arguments: index);
              },
            ),
          );
        },
      ),
    );
  }
}
