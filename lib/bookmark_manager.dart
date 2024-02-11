import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// The directory in which all bookmarks live
Future<String> _bookmarksDir() async {
  final appDir = await getApplicationDocumentsDirectory();
  return "${appDir.path}${Platform.pathSeparator}hisnhaseen";
}

/// Represents a bookmark folder
class BookmarkFolder {
  /// the actual name of the file that it represents
  final String folderName;

  /// The display name of this folder
  final String displayName;

  BookmarkFolder({required this.folderName, required this.displayName});
}

class BookmarkManager {
  BookmarkManager._private();
  static final BookmarkManager _instance = BookmarkManager._private();

  /// Gets the singleton instance of BookmarkManager
  static BookmarkManager get instance => _instance;

  bool _initialized = false;
  List<BookmarkFolder>? folders;

  /// Initializes the manager
  void init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      // Ensure bookmarks folder exists
      Directory d = Directory(await _bookmarksDir());
      d.createSync();
      // Create _uncategorized folder
      createNewFolder("_uncategorized");
    } catch (_) {}
  }

  /// Creates a new bookmark folder
  /// A bookmark folder is just a json file underneath
  void createNewFolder(String name) async {
    // A bookmark folder is basically just a json file
    String displayName = name;
    name = "BK_$name.json";
    // docs/hisnhaseen/
    String bookmarkDir = await _bookmarksDir();
    String newFolder = "$bookmarkDir${Platform.pathSeparator}$name";
    final f = File(newFolder);
    if (f.existsSync()) {
      return;
    }

    f.createSync();

    assert(folders != null); // we must have folders initialized by now
    folders?.add(BookmarkFolder(displayName: displayName, folderName: name));
  }

  /// Gets the list of bookmark folders
  /// We only fetch the folders from disk once i.e., the
  /// the first time this method is called
  Future<List<BookmarkFolder>> getBookmarkFolders() async {
    if (folders != null) {
      return folders!;
    }

    final bookmarksDir = Directory(await _bookmarksDir());
    final entries = bookmarksDir.listSync();
    folders = [];
    for (final e in entries) {
      if (e is File) {
        final name = e.uri.pathSegments.last;
        final extIdx = name.lastIndexOf(".json");
        if (name.startsWith("BK_") && extIdx != -1) {
          String displayName = name.substring(3, extIdx);
          displayName =
              displayName == "_uncategorized" ? "Uncategorized" : displayName;
          folders!.add(BookmarkFolder(
            folderName: name,
            displayName: displayName,
          ));
        }
      }
    }
    return folders!;
  }

  void bookmarkDua(
      BookmarkFolder folder, int categoryIndex, String duaId) async {
    final dir = await _bookmarksDir();
    String file = "$dir${Platform.pathSeparator}${folder.folderName}";
    print("Saving to $file");
    File f = File(file);
    String existing = f.readAsStringSync();
    existing += "$categoryIndex:$duaId\n";

    File w = File(file);
    w.writeAsStringSync(existing);
  }
}
