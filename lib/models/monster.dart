class Monster {
  final String index;
  final String name;
  final String? url;
  final int? hitPoints;
  final int? armorClass;
  final double? challengeRating;
  final String? imageUrl;
  final List<MonsterAction> actions;

  Monster({
    required this.index,
    required this.name,
    this.url,
    this.hitPoints,
    this.armorClass,
    this.challengeRating,
    this.imageUrl,
    this.actions = const [],
  });

  factory Monster.fromJson(Map<String, dynamic> json) {
    return Monster(
      index: json['index'],
      name: json['name'],
      url: json['url'],
      hitPoints: json['hit_points'] as int?,
      armorClass: _parseArmorClass(json['armor_class']),
      challengeRating: (json['challenge_rating'] as num?)?.toDouble(),
      imageUrl: _normalizeImageUrl(json['image'] as String?),
      actions: (json['actions'] as List<dynamic>? ?? [])
          .map(
            (action) => MonsterAction.fromJson(action as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  static int? _parseArmorClass(dynamic armorClassJson) {
    if (armorClassJson is int) {
      return armorClassJson;
    }

    if (armorClassJson is List && armorClassJson.isNotEmpty) {
      final first = armorClassJson.first;
      if (first is Map<String, dynamic>) {
        return first['value'] as int?;
      }
    }

    return null;
  }

  static String? _normalizeImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    return 'https://www.dnd5eapi.co$imagePath';
  }
}

class MonsterAction {
  final String name;
  final String desc;
  final int? attackBonus;
  final List<MonsterDamage> damage;

  MonsterAction({
    required this.name,
    required this.desc,
    this.attackBonus,
    this.damage = const [],
  });

  factory MonsterAction.fromJson(Map<String, dynamic> json) {
    return MonsterAction(
      name: json['name'] as String? ?? 'Ataque',
      desc: json['desc'] as String? ?? '',
      attackBonus: json['attack_bonus'] as int?,
      damage: (json['damage'] as List<dynamic>? ?? [])
          .map((entry) => MonsterDamage.fromJson(entry as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MonsterDamage {
  final String? damageDice;
  final String? damageType;

  MonsterDamage({this.damageDice, this.damageType});

  factory MonsterDamage.fromJson(Map<String, dynamic> json) {
    final damageType = json['damage_type'] as Map<String, dynamic>?;

    return MonsterDamage(
      damageDice: json['damage_dice'] as String?,
      damageType: damageType?['name'] as String?,
    );
  }
}
