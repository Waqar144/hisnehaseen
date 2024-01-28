import 'package:flutter/material.dart';

import 'settings.dart';

const String appVersion = "1.1.1";

String _themeModeToString(ThemeMode m) {
  return switch (m) {
    ThemeMode.system => "System",
    ThemeMode.light => "Light",
    ThemeMode.dark => "Dark",
  };
}

class SettingsPage extends StatefulWidget {
  final List<ThemeMode> themeModes = ThemeMode.values;
  SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode themeMode = Settings.instance.themeMode;

  // void _showError(String message) async {
  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Error'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text(message),
  //               const Text(
  //                   "Please try again. If the error persists please report a bug."),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('Ok'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Widget _createThemeModeTile() {
    return ListTile(
      title: const Text("Theme"),
      subtitle: const Text("Switch between light or dark mode"),
      trailing: SizedBox(
        width: 100,
        child: DropdownButtonFormField<ThemeMode>(
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          decoration: const InputDecoration(contentPadding: EdgeInsets.all(8)),
          value: themeMode,
          onChanged: (ThemeMode? val) {
            if (val != null) {
              themeMode = val;
              Settings.instance.themeMode = val;
            }
          },
          padding: EdgeInsets.zero,
          items: [
            for (final themeMode in widget.themeModes)
              DropdownMenuItem(
                value: themeMode,
                child: Text(_themeModeToString(themeMode)),
              )
          ],
        ),
      ),
    );
  }

  Widget _version() {
    return ListTile(
      leading: const Icon(Icons.app_settings_alt),
      title: const Text("App version"),
      subtitle: const Text(appVersion),
      onTap: () async {
        // await launchUrl(
        //     Uri.parse(
        //         "https://github.com/Waqar144/quran_memorization_helper/releases"),
        //     mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _reportAnIssue() {
    return ListTile(
      leading: const Icon(Icons.bug_report),
      title: const Text("Report a bug/issue"),
      subtitle:
          const Text("Faced an issue or have a suggestion? Tap to report"),
      onTap: () async {
        // await launchUrl(
        //     Uri.parse(
        //         "https://github.com/Waqar144/quran_memorization_helper/issues"),
        //     mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _email() {
    return ListTile(
      leading: const Icon(Icons.email),
      title: const Text("Email support"),
      subtitle: const Text("Reach out to us via email directly"),
      onTap: () async {
        // await launchUrl(Uri.parse("support@streetwriters.co"),
        //     mode: LaunchMode.externalApplication);
      },
    );
  }

  Widget _licenses() {
    return ListTile(
      leading: const Icon(Icons.policy),
      title: const Text("View licenses"),
      subtitle:
          const Text("View licenses of open source libraries used in this app"),
      onTap: () async {
        showLicensePage(
          context: context,
          applicationVersion: appVersion,
          applicationName: "Quran 16 Line",
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          _createThemeModeTile(),
          // _createFontSizeTile(),
          const Divider(),
          _reportAnIssue(),
          _email(),
          const Divider(),
          _licenses(),
          _version(),
        ],
      ),
    );
  }
}
