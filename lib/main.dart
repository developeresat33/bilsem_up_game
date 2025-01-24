import 'package:bilsemup_minigame/pages/game_list.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
    DeviceOrientation.portraitDown, 
  ]);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => GameProvider()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bilsemup Minigame',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GameList(),
    );
  }
}
