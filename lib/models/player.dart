class Player {
  String name;
  int bonusInitiative;
  int maxHp;
  int currentHp;
  int cA;

  Player({
    required this.name,
    required this.bonusInitiative,
    required this.maxHp,
    required this.currentHp,
    required this.cA,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'bonusInitiative': bonusInitiative,
      'maxHp': maxHp,
      'currentHp': currentHp,
      'cA': cA,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String? ?? '',
      bonusInitiative: json['bonusInitiative'] as int? ?? 0,
      maxHp: json['maxHp'] as int? ?? 0,
      currentHp: (json['currentHp'] as int?) ?? (json['maxHp'] as int? ?? 0),
      cA: json['cA'] as int? ?? 0,
    );
  }
}
