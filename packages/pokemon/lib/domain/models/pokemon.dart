import 'type.dart';

class Pokemon {
  final int id;
  final String name;
  final Uri imageUrl;
  final List<Type> types;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.types,
  });
}
