import 'package:flutter/material.dart';

import 'detail_view.dart';
import 'home_page.dart';

class Routes {
  static const String showCategory = "showCategory";
}

MaterialPageRoute onGenerateRoute(RouteSettings? settings) {
  return MaterialPageRoute(
    builder: (context) {
      return switch (settings?.name ?? "") {
        Routes.showCategory => DetailsView(settings!.arguments as int),
        _ => const HomePage(title: 'Al-Hisn Al-Haseen')
      };
    },
  );
}
