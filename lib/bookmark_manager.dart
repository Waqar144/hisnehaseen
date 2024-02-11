// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'dart:convert';
import 'utils.dart' as utils;

class Bookmark {
  final int categoryIndex;
  final int duaId;

  Bookmark({required this.categoryIndex, required this.duaId});
  static Bookmark? parse(String raw) {
    List<String> parts = raw.split(":");
    if (parts.length != 2) return null;
    int? c = int.tryParse(parts[0]);
    int? d = int.tryParse(parts[1]);
    if (c != null && d != null) {
      return Bookmark(categoryIndex: c, duaId: d);
    }
    return null;
  }

  String toRaw() {
    return "$categoryIndex:$duaId";
  }

  @override
  bool operator ==(Object other) {
    return (other is Bookmark) &&
        other.categoryIndex == categoryIndex &&
        other.duaId == duaId;
  }

  @override
  int get hashCode => Object.hash(categoryIndex, duaId);
}

/// Represents a bookmark folder
class BookmarkFolder {
  /// The display name of this folder
  final String displayName;

  final List<Bookmark> bookmarks;

  BookmarkFolder({required this.displayName, required this.bookmarks});

  static BookmarkFolder fromJson(String name, List<dynamic> bookmarks) {
    List<Bookmark> bookmarks = [];
    for (final b in bookmarks) {
      Bookmark? bookmark = Bookmark.parse(b as String);
      if (bookmark != null) {
        bookmarks.add(bookmark);
      }
    }

    return BookmarkFolder(
      displayName: name,
      bookmarks: bookmarks,
    );
  }

  List<dynamic> rawBookmarks() {
    List<dynamic> rawBookmarks = [for (final b in bookmarks) b.toRaw()];
    return rawBookmarks;
  }
}

class BookmarkManager {
  BookmarkManager._private();
  static final BookmarkManager _instance = BookmarkManager._private();

  /// Gets the singleton instance of BookmarkManager
  static BookmarkManager get instance => _instance;

  bool _initialized = false;
  List<BookmarkFolder> folders = [];
  final Set<Bookmark> _bookmarks = {};

  /// Initializes the manager
  void init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Ensure bookmarks folder exists
      final json = await utils.readJsonFile("hisnhaseen_bookmarks");
      folders = [];
      for (final kv in json.entries) {
        final folder = BookmarkFolder.fromJson(kv.key, kv.value as List);
        _bookmarks.addAll(folder.bookmarks);
        folders.add(folder);
      }

      if (folders.isEmpty) {
        // Create _uncategorized folder
        createNewFolder("Uncategorized");
      }
    } catch (_) {}
  }

  /// Creates a new bookmark folder
  /// A bookmark folder is just a json file underneath
  void createNewFolder(String name) {
    for (final f in folders) {
      if (f.displayName == name) {
        throw "Folder already exists";
      }
    }
    folders.add(BookmarkFolder(displayName: name, bookmarks: []));
  }

  /// Gets the list of bookmark folders
  /// We only fetch the folders from disk once i.e., the
  /// the first time this method is called
  List<BookmarkFolder> getBookmarkFolders() {
    return folders;
  }

  void bookmarkDua(
      BookmarkFolder folder, int categoryIndex, String duaId) async {
    for (final f in folders) {
      if (f.displayName == folder.displayName) {
        final b =
            Bookmark(categoryIndex: categoryIndex, duaId: int.parse(duaId));
        f.bookmarks.add(b);
        _bookmarks.add(b);
        // trigger save to disk
        _saveToDisk();
      }
    }
  }

  void removeBookmark(int categoryIndex, String duaId) {
    final b = Bookmark(categoryIndex: categoryIndex, duaId: int.parse(duaId));
    _bookmarks.remove(b);
    for (final f in folders) {
      f.bookmarks.remove(b);
      // trigger save to disk
    }
    _saveToDisk();
  }

  bool isDuaBookmarked(int categoryIndex, String duaId) {
    int? d = int.tryParse(duaId);
    if (d == null) return false;
    final b = Bookmark(categoryIndex: categoryIndex, duaId: d);
    return _bookmarks.contains(b);
  }

  void _saveToDisk() {
    Map<String, dynamic> map = {};
    for (final f in folders) {
      map[f.displayName] = f.rawBookmarks();
    }
    String json = jsonEncode(map);
    utils.saveJsonToDisk(json, "hisnhaseen_bookmarks");
  }
}
