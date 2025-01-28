import 'package:flutter/material.dart';

class LevelTile extends StatelessWidget {
  final String levelName;
  final String? description;
  final IconData? icon;
  final VoidCallback? onTap;

  const LevelTile({
    Key? key,
    required this.levelName,
    this.description,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4), // Dikey aralık
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[850]!.withOpacity(0.4), // Koyu arka plan rengi
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Level $levelName",
                    style: TextStyle(
                      color: Colors.white, // Başlık rengi
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  if (description != null)
                    Text(
                      description!,
                      style: TextStyle(
                        color: Colors.white60, // Açıklama metni rengi
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Icon(
              icon ?? Icons.play_arrow,
              size: 40,
              color: Colors.white70, // İkon rengi
            ),
          ],
        ),
      ),
    );
  }
}
