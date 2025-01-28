import 'package:bilsemup_minigame/pages/dot_connect/dot_connect.dart';
import 'package:bilsemup_minigame/pages/dot_connect/menu/widgets/level_tile.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DotGameLevels extends StatefulWidget {
  const DotGameLevels({
    super.key,
  });

  @override
  State<DotGameLevels> createState() => _DotGameLevelsState();
}

class _DotGameLevelsState extends State<DotGameLevels> {
  var value = Provider.of<GameProvider>(Get.context!, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, _value, child) => WillPopScope(
          onWillPop: () async {
            if (_value.pageController != null &&
                _value.pageController!.hasClients) {
              await _value.pageController!.animateToPage(
                0,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }

            _value.setCurrentPage(0);

            return false;
          },
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
       
              Expanded(
                  child: ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: _value.levels.length,
                      itemBuilder: (context, index) {
                        return LevelTile(
                          levelName: _value.levels[index].level.toString(),
                          onTap: () async {
                            _value.selectedLevel = _value.levels[index];
                            Get.to(() => DotGameScreen());
                          },
                        );
                      })),
              SizedBox(
                height: 70,
              ),
            ],
          )),
    );
  }
}
