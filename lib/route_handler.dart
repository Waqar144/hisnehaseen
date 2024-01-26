import 'package:flutter/material.dart';

import 'detail_view.dart';
import 'home_page.dart';
import 'asma_ul_husna.dart';

class Routes {
  static const String showCategory = "showCategory";
}

Widget handleChapter(int index) {
  if (index == 9) {
    return const AsmaulHusna();
  }
  return DetailsView(index);
}

MaterialPageRoute onGenerateRoute(RouteSettings? settings) {
  return MaterialPageRoute(
    builder: (context) {
      return switch (settings?.name ?? "") {
        Routes.showCategory => handleChapter(settings?.arguments as int),
        _ => const HomePage(title: 'Al-Hisn Al-Haseen')
      };
    },
  );
}
