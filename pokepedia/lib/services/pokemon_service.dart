import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  Future<List<PokemonModel>> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      List<PokemonModel> pokemonDetails = [];
      for (var item in results) {
        final detailResponse = await http.get(Uri.parse(item['url']));
        if (detailResponse.statusCode == 200) {
          final detailData = json.decode(detailResponse.body);
          pokemonDetails.add(PokemonModel.fromJson(detailData));
        }
      }
      return pokemonDetails;
    } else {
      throw Exception('Failed to load pokemon list');
    }
  }

  Future<PokemonModel> fetchPokemonDetail(String nameOrId) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$nameOrId'));

    if (response.statusCode == 200) {
      return PokemonModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load pokemon detail');
    }
  }
}
