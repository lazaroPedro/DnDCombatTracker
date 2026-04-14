import 'dart:math';

import 'package:dnd_combat_tracker/models/monster.dart';

enum CombatantType { player, monster }

extension CombatantTypeLabel on CombatantType {
  String get label {
    switch (this) {
      case CombatantType.player:
        return 'Jogador';
      case CombatantType.monster:
        return 'Monstro';
    }
  }
}

class Combatant {
  Combatant({
    required this.id,
    required this.name,
    required this.initiative,
    required this.type,
    required this.maxHp,
    required this.currentHp,
    required this.armorClass,
    this.imageUrl,
    this.monsterActions = const [],
  });

  final String id;
  final String name;
  final int initiative;
  final CombatantType type;
  final int maxHp;
  int currentHp;
  final int armorClass;
  final String? imageUrl;
  final List<MonsterAction> monsterActions;

  bool get isDefeated => currentHp <= 0;

  double get healthRatio {
    if (maxHp <= 0) {
      return 0;
    }

    return currentHp.clamp(0, maxHp) / maxHp;
  }

  void applyDamage(int damage) {
    currentHp = max(0, currentHp - damage);
  }
}
