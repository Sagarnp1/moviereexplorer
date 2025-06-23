import 'package:flutter/material.dart';
import '../models/genre.dart';

class GenreChip extends StatelessWidget {
  final Genre genre;
  final VoidCallback onTap;

  const GenreChip({
    Key? key,
    required this.genre,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: genre.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: genre.color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(genre.icon, color: genre.color, size: 16),
            const SizedBox(width: 6),
            Text(
              genre.name,
              style: TextStyle(
                color: genre.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
