import 'package:flutter/material.dart';

import 'detail_view.dart';
import 'home_page.dart';

MaterialPageRoute onGenerateRoute(RouteSettings? settings) {
  return MaterialPageRoute(
    builder: (context) {
      return switch (settings?.name ?? "") {
        "a" => DetailsView(),
        _ => const HomePage(title: 'Al-Hisn Al-Haseen')
      };
    },
  );
}
