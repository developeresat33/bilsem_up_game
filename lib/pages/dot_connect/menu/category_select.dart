import 'package:bilsemup_minigame/data/level_data.dart';
import 'package:bilsemup_minigame/pages/dot_connect/menu/widgets/category_tile.dart';
import 'package:bilsemup_minigame/states/game_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DotGameCategories extends StatefulWidget {
  const DotGameCategories({super.key});

  @override
  State<DotGameCategories> createState() => _DotGameCategoriesState();
}

class _DotGameCategoriesState extends State<DotGameCategories> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
        builder: (context, _value, child) => Column(
              children: [
                SizedBox(
                  height: 10,
                ),
     
                Expanded(
                    child: GridView.builder(
                        physics: BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: LevelData.categoryNames.length,
                        itemBuilder: (context, index) {
                          return CategoryTile(
                            title: LevelData.categoryNames[index],
                            onTap: () {
                              _value.loadLevels(
                                  LevelData.categoryNames[index].split(" ")[0]);
                            },
                          );
                        })),
                SizedBox(
                  height: 70,
                ),
              ],
            ));
  }
}
