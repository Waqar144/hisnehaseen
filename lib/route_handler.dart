import 'package:flutter/material.dart';

import 'detail_view.dart';
import 'home_page.dart';
import 'asma_ul_husna.dart';
import 'settings_page.dart';
import 'bookmarks_page.dart';
import 'bookmark_manager.dart';

class Routes {
  static const String showCategory = "showCategory";
  static const String settings = "settings";
  static const String bookmarks = "bookmarks";
  static const String openBookmarkFolder = "openBookmarkFolder";
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
        Routes.settings => SettingsPage(),
        Routes.bookmarks => const BookmarksPage(),
        Routes.openBookmarkFolder =>
          BookmarkFolderPage(folder: settings?.arguments as BookmarkFolder),
        _ => const HomePage(title: 'Al-Hisn Al-Haseen')
      };
    },
  );
}
