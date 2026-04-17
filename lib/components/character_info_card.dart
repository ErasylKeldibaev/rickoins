import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/character_model.dart';

class CharacterInfoCard extends StatelessWidget {
  final CharacterModel character;

  const CharacterInfoCard({
    super.key,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: character.image,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const SizedBox(
                      height: 110,
                      width: 110,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => const SizedBox(
                      height: 110,
                      width: 110,
                      child: Icon(Icons.error),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _row('Name', character.name, bold: true),
              _row('Status', character.status),
              _row('Species', character.species),
              _row('Gender', character.gender),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          style: const TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}