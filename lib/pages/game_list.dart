import 'package:bilsemup_minigame/data/general.dart';
import 'package:bilsemup_minigame/pages/simple_box_game.dart';
import 'package:bilsemup_minigame/pages/simple_box_game_2.dart';
import 'package:bilsemup_minigame/pages/match_game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GameList extends StatefulWidget {
  const GameList({super.key});

  @override
  State<GameList> createState() => _GameListState();
}

class _GameListState extends State<GameList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Bilsem Up Oyunları', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      final gameEntry =
                          GeneralDefinition.games.entries.elementAt(index);
                      final gameName = gameEntry.key;
                      final gameValue = gameEntry.value;
                      return Card(
                        child: ListTile(
                          title: Text(
                            gameName,
                            style: TextStyle(color: Colors.black54),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Colors.blueAccent[800]),
                          onTap: () {
                            switch (gameValue) {
                              case 0:
                                Get.to(() => SimpleBoxGame());

                                break;

                              case 1:
                                Get.to(() => SimpleBoxGame2());
                                break;

                              case 2:
                                Get.to(() => MatchGame());
                                break;
                              default:
                                break;
                            }
                          },
                        ),
                      );
                    },
                    itemCount: GeneralDefinition.games.length)),
          ],
        ),
      ),
    );
  }
}
