import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_model.dart';

Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Colors.orangeAccent;
      case 'water':
        return Colors.blueAccent;
      case 'grass':
        return Colors.greenAccent;
      case 'electric':
        return Colors.yellowAccent;
      case 'poison':
        return Colors.purpleAccent;
      case 'ground':
        return Colors.brown;
      case 'flying':
        return Colors.indigoAccent;
      case 'psychic':
        return Colors.pinkAccent;
      case 'bug':
        return Colors.lightGreenAccent;
      case 'rock':
        return Colors.grey;
      case 'ghost':
        return Colors.deepPurple;
      case 'dragon':
        return Colors.indigo;
      default:
        return Colors.tealAccent;
    }
  }

Widget pokemonCard(PokemonModel pokemon) {
    final typeColor = _getTypeColor(pokemon.type);
    return Container(
      decoration: BoxDecoration(
        color: typeColor.withAlpha(60),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: typeColor.withAlpha(90), width: 1),
        boxShadow: [
          BoxShadow(
            color: typeColor.withAlpha(60),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () {
            // Navigate to detail screen
          },
          child: Stack(
            children: [
              Positioned(
                bottom: -20,
                right: -20,
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(
                    Icons.catching_pokemon,
                    size: 100,
                    color: typeColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '#${pokemon.id.toString().padLeft(3, '0')}',
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            pokemon.type.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Center(
                        child: Hero(
                          tag: 'pokemon-${pokemon.id}',
                          child: CachedNetworkImage(
                            imageUrl: pokemon.imageUrl,
                            placeholder: (context, url) => const SizedBox(
                              width: 30,
                              height: 30,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pokemon.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
