import 'package:bilsemup_minigame/pages/simple_box_game.dart';
import 'package:bilsemup_minigame/states/box_game_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => MemoryGameProvider()),
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
      home: SimpleBoxGame(),
    );
  }
}
