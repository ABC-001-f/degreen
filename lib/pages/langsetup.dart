import 'package:degreen/topics.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Langsetup extends StatefulWidget {
  const Langsetup({super.key});

  @override
  State<Langsetup> createState() => _LangsetupState();
}

class _LangsetupState extends State<Langsetup> {
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.chevron_left),
          ),
        ),
        title: const Text("Set Language"),
        centerTitle: true,
        actions: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.energy_savings_leaf,
              color: Colors.green,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: Topics().languages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(Topics().languages[index]['name']!),
            onTap: () {
              settingsProvider.setLang(Topics().languages[index]['code']!);
              Navigator.pop(context);
            },
            trailing: settingsProvider.settings.language ==
                    Topics().languages[index]['code']!
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green,
                  )
                : const SizedBox(),
          );
        },
      ),
    );
  }
}
