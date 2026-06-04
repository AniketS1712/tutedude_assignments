class PokemonModel {
  final String name;
  final String ability;
  final String type;
  final int id;

  PokemonModel({
    required this.name,
    required this.ability,
    required this.type,
    required this.id,
  });

  factory PokemonModel.fromJson(Map<String, dynamic> json) {
    return PokemonModel(
      name: json['name'] ?? '',
      ability: (json['abilities'] != null && json['abilities'].isNotEmpty)
          ? json['abilities'][0]['ability']['name']
          : 'Unknown',
      type: (json['types'] != null && json['types'].isNotEmpty)
          ? json['types'][0]['type']['name']
          : 'Unknown',
      id: json['id'] ?? 0,
    );
  }

  String get imageUrl =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
}
