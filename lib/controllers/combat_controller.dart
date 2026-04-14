import 'package:flutter/material.dart';
import '../models/combatant.dart';

class CombatController extends ChangeNotifier {
  CombatController(List<Combatant> initialCombatants) {
    _combatants = List.from(initialCombatants);
    _syncCurrentTurnToActive();
  }

  late final List<Combatant> _combatants;
  int _currentTurnIndex = 0;
  int _round = 1;


  List<Combatant> get combatants => _combatants;
  int get round => _round;
  Combatant get currentCombatant => _combatants[_currentTurnIndex];


  List<Combatant> livingOpponentsOf(CombatantType type) {
    return _combatants.where((c) => c.type != type && !c.isDefeated).toList();
  }


  bool get playersDefeated => !_combatants.any((c) => c.type == CombatantType.player && !c.isDefeated);
  bool get monstersDefeated => !_combatants.any((c) => c.type == CombatantType.monster && !c.isDefeated);


  List<Combatant> get displayOrder {
    final alive = <Combatant>[];
    final defeated = <Combatant>[];

    for (var offset = 0; offset < _combatants.length; offset++) {
      final index = (_currentTurnIndex + offset) % _combatants.length;
      final combatant = _combatants[index];
      if (combatant.isDefeated) {
        defeated.add(combatant);
      } else {
        alive.add(combatant);
      }
    }
    return [...alive, ...defeated];
  }


  void applyDamage(String targetId, int damage) {
    final target = _combatants.firstWhere((c) => c.id == targetId);
    target.applyDamage(damage);
    _syncCurrentTurnToActive();
    notifyListeners(); 
  }


  void advanceTurn() {
    if (_combatants.isEmpty) return;

    final currentIndex = _currentTurnIndex;
    var nextIndex = currentIndex;

    do {
      nextIndex = (nextIndex + 1) % _combatants.length;
      if (nextIndex == 0) _round++;
    } while (_combatants[nextIndex].isDefeated && nextIndex != currentIndex);

    _currentTurnIndex = nextIndex;
    _syncCurrentTurnToActive();
    notifyListeners();
  }

  void _syncCurrentTurnToActive() {
    if (_combatants.isEmpty || !_combatants[_currentTurnIndex].isDefeated) return;

    for (var i = 0; i < _combatants.length; i++) {
      final index = (_currentTurnIndex + i) % _combatants.length;
      if (!_combatants[index].isDefeated) {
        _currentTurnIndex = index;
        return;
      }
    }
  }
}