import 'package:flutter/material.dart';

import 'home_page.dart';
import 'route_handler.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Settings.instance.readSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Settings.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'Al Hisn Al Haseen',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
          ),
          themeMode: Settings.instance.themeMode,
          debugShowCheckedModeBanner: false,
          home: const HomePage(title: 'Al-Hisn Al-Haseen'),
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
