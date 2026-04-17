class CharacterModel {
  final int id;
  final String name;
  final String status;
  final String species;
  final String gender;
  final String image;

  const CharacterModel({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.gender,
    required this.image,
  });

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      id: (map['id'] as num?)?.toInt() ?? 0,
      name: map['name']?.toString() ?? 'Unknown',
      status: map['status']?.toString() ?? 'Unknown',
      species: map['species']?.toString() ?? 'Unknown',
      gender: map['gender']?.toString() ?? 'Unknown',
      image: map['image']?.toString() ?? '',
    );
  }
}