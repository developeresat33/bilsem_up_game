import 'package:animated_background/animated_background.dart';
import 'package:bilsemup_minigame/pages/dot_connect/menu/category_select.dart';
import 'package:bilsemup_minigame/pages/dot_connect/menu/level_select.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class DotGameMenu extends StatefulWidget {
  const DotGameMenu({super.key});

  @override
  State<DotGameMenu> createState() => _DotGameMenuState();
}

class _DotGameMenuState extends State<DotGameMenu>
    with TickerProviderStateMixin {
  var value = Provider.of<GameProvider>(Get.context!, listen: false);

  @override
  void initState() {
    value.selectedLevel = null;

    super.initState();
    _init();
  }

  void _initAudio() async {
    FlameAudio.bgm.play('sound/ethernal.mp3', volume: 0.8);
    value.isPaused = false;
  }

  _init() async {
    value.currentPage = 0;
    value.pageController = PageController();
    _initAudio();
  }

  @override
  void dispose() {
    if (FlameAudio.bgm.isPlaying) {
      try {
        FlameAudio.bgm.stop();
      } catch (e) {
        print("Audio already disposed: $e");
      }
    }
    value.disposeAnimateControllers();
    if (value.pageController != null) {
      value.pageController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
        builder: (context, _value, child) => SafeArea(
              child: Scaffold(
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.startFloat,
                  floatingActionButton: _value.currentPage != 0
                      ? FloatingActionButton(
                          backgroundColor:
                              Color.fromARGB(255, 34, 34, 34).withOpacity(0.8),
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            _value.pageController!.animateToPage(
                              0,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                            _value.setCurrentPage(0);
                          },
                        )
                      : null,
                  backgroundColor: const Color.fromARGB(255, 19, 19, 19),
                  body: AnimatedBackground(
                      vsync: this,
                      behaviour: RandomParticleBehaviour(
                          options: ParticleOptions(
                              image: Image.asset(
                                'assets/img/space.png',
                              ),
                              particleCount: 30,
                              spawnOpacity: 0.1,
                              spawnMaxSpeed: 50,
                              spawnMaxRadius: 20,
                              spawnMinSpeed: 15,
                              baseColor: Colors.white),
                          paint: Paint()),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Dot Connect v1.0 BilsemUp",
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Color.fromARGB(255, 34, 34, 34)
                                    .withOpacity(0.8),
                                child: IconButton(
                                  icon: Icon(
                                    !value.isPaused
                                        ? Icons.music_note
                                        : Icons.music_off,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    _value.startStopBgmMusic();
                                  },
                                ),
                              )
                            ],
                          ),
                          Expanded(
                              child: PageView(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _value.pageController,
                            children: [DotGameCategories(), DotGameLevels()],
                          )),
                        ],
                      ).paddingSymmetric(horizontal: 10, vertical: 10)

                      /* ListView(
                      children: _value.groupedLevels.entries.map((entry) {
                        int gridSize = entry.key;
                        List<LevelData> levelsForGrid = entry.value;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Grid Size: $gridSize (${levelsForGrid.length} Levels)',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70),
                              ),
                            ),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Her satırda 2 öğe
                                childAspectRatio: 3, // Öğelerin yüksekliği
                              ),
                              itemCount: levelsForGrid.length,
                              itemBuilder: (context, index) {
                                LevelData level = levelsForGrid[index];
                                return Card(
                                  color: Color.fromARGB(255, 32, 29, 29),
                                  surfaceTintColor:
                                      Color.fromARGB(255, 24, 23, 23),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(10),
                                    onTap: () async {
                                      _value.selectedLevel = level;
                                      Get.to(() => DotGameScreen());
                                    },
                                    child: Center(
                                      child: Text(
                                        'Level ${level.level}',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Divider(
                              thickness: 2,
                              color: Colors.white60,
                            ), // Grupları ayıran çizgi
                          ],
                        );
                      }).toList(),
                    ), */
                      )),
            ));
  }
}
