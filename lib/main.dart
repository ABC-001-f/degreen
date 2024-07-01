import 'package:degreen/pages/home.dart';
import 'package:degreen/utils/settings_provider.dart';
import 'package:degreen/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await StorageHelper.init();
  runApp(const MyApp());
  doWhenWindowReady(() {
    const initialSize = Size(500, 450);
    appWindow.minSize = initialSize;
    appWindow.size = const Size(1000, 560);
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          final isDarkMode = settingsProvider.settings.dark;
          final brightness = isDarkMode ? Brightness.dark : Brightness.light;
          return MaterialApp(
            title: 'De Green',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.green,
                brightness: brightness,
              ),
              useMaterial3: true
            ),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
