sealed class Type {
  final String name;

  Type({required this.name});
}

class Normal extends Type {
  Normal() : super(name: 'normal');
}

class Fire extends Type {
  Fire() : super(name: 'fire');
}

class Water extends Type {
  Water() : super(name: 'water');
}

class Grass extends Type {
  Grass() : super(name: 'grass');
}

class Electric extends Type {
  Electric() : super(name: 'electric');
}

class Ice extends Type {
  Ice() : super(name: 'ice');
}

class Fighting extends Type {
  Fighting() : super(name: 'fighting');
}

class Poison extends Type {
  Poison() : super(name: 'poison');
}

class Ground extends Type {
  Ground() : super(name: 'ground');
}

class Flying extends Type {
  Flying() : super(name: 'flying');
}

class Psychic extends Type {
  Psychic() : super(name: 'psychic');
}

class Bug extends Type {
  Bug() : super(name: 'bug');
}

class Rock extends Type {
  Rock() : super(name: 'rock');
}

class Ghost extends Type {
  Ghost() : super(name: 'ghost');
}

class Dragon extends Type {
  Dragon() : super(name: 'dragon');
}

class Dark extends Type {
  Dark() : super(name: 'dark');
}

class Steel extends Type {
  Steel() : super(name: 'steel');
}

class Fairy extends Type {
  Fairy() : super(name: 'fairy');
}
