import 'package:degreen/pages/langsetup.dart';
import 'package:degreen/topics.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settingspage extends StatefulWidget {
  const Settingspage({super.key});

  @override
  State<Settingspage> createState() => _SettingspageState();
}

class _SettingspageState extends State<Settingspage> {
  String namelang = "Choose your prefered language";
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    String deviceType = "";
    if (screenWidth >= 1200) {
      deviceType = 'huge';
    } else if (screenWidth >= 700) {
      deviceType = 'tablet';
    } else {
      deviceType = 'mobile';
    }
    final settingsProvider = Provider.of<SettingsProvider>(context);
    for (var element in Topics().languages) {
      if (element['code'] == settingsProvider.settings.language) {
        namelang = element['name']!;
      }
    }
    return Scaffold(
        appBar: AppBar(
          leading: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: const Icon(Icons.chevron_left),
            ),
          ),
          title: const Text("Settings"),
          centerTitle: true,
          actions: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                "lib/assets/new degreen ic.png",
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            child: deviceType == "mobile"
                ? Column(
                    children: lister(settingsProvider, "m"),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    children: lister(settingsProvider, "h"),
                  ),
          ),
        ));
  }

  List<Widget> lister(settingsProvider, String type) {
    return [
      boxcontainer(
        context: context,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Dark",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoSwitch(
                  value: settingsProvider.settings.dark,
                  onChanged: (value) {
                    settingsProvider.toggleDarkMode(value);
                  },
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(
                width: double.infinity,
                child: Text(
                  "Switch themes to your desired taste",
                ))
          ],
        ),
        type: type,
      ),
      boxcontainer(
        context: context,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Fast Speech",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                CupertinoSwitch(
                  value: settingsProvider.settings.fast,
                  onChanged: (value) {
                    settingsProvider.toggleFastspeech(value);
                  },
                )
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(
                width: double.infinity,
                child: Text(
                  "Voice when reading to you",
                ))
          ],
        ),
        type: type,
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const Langsetup(),
            ));
          },
          child: boxcontainer(
            context: context,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Language",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Icon(Icons.language),
                    )
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                ),
                SizedBox(
                    width: double.infinity,
                    child: Text(
                      namelang,
                    ))
              ],
            ),
            type: type,
          ),
        ),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            settingsProvider.resetAll();
          },
          child: boxcontainer(
            context: context,
            child: const Text(
              "Reset to default",
              textAlign: TextAlign.center,
            ),
            type: 'm',
          ),
        ),
      ),
      boxcontainer(
        context: context,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Powered with Gemini AI",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Image.asset(
                  "lib/assets/gemini logo.png",
                  width: 30,
                  height: 30,
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const Divider(
              color: Colors.grey,
            ),
            const SizedBox(
              width: double.infinity,
              child: Text(
                "your informative, comprehensive, and ever-evolving AI companion.",
              ),
            )
          ],
        ),
        type: 'm',
      ),
      const SizedBox(
        height: 10,
      ),
    ];
  }

  Container boxcontainer({
    required BuildContext context,
    required Widget child,
    required String type,
  }) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        width: type == "m" ? double.infinity : 300,
        margin: const EdgeInsets.only(top: 10, left: 25, right: 25),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Theme.of(context).hoverColor),
        child: child);
  }
}
