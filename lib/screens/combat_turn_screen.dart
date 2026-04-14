import 'dart:math';
import 'package:flutter/material.dart';
import '../controllers/combat_controller.dart';
import '../models/combatant.dart';
import '../services/roll_dice_service.dart';
import '../widgets/player_damage_modal.dart';
import '../widgets/monster_attack_modal.dart';
import '../widgets/monster_attack_result_modal.dart';
import '../widgets/combatant_hp_modal.dart';

class CombatTurnScreen extends StatefulWidget {
  const CombatTurnScreen({super.key, required this.combatants});
  final List<Combatant> combatants;

  @override
  State<CombatTurnScreen> createState() => _CombatTurnScreenState();
}

class _CombatTurnScreenState extends State<CombatTurnScreen> {
  late final CombatController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = CombatController(widget.combatants);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _playerAttack() async {
    final targets = _ctrl.livingOpponentsOf(CombatantType.player);
    if (targets.isEmpty) return;

    final result = await showModalBottomSheet<PlayerDamageResult>(
      context: context,
      isScrollControlled: true,
      builder: (c) => PlayerDamageModal(
        attackerName: _ctrl.currentCombatant.name,
        livingMonsters: targets,
      ),
    );

    if (result != null) _ctrl.applyDamage(result.targetId, result.damage);
  }

  Future<void> _monsterAttack() async {
    final m = _ctrl.currentCombatant;
    final actions = m.monsterActions.where((a) => a.attackBonus != null).toList();
    final targets = _ctrl.livingOpponentsOf(CombatantType.monster);
    if (actions.isEmpty || targets.isEmpty) return;

    final plan = await showModalBottomSheet<MonsterAttackPlan>(
      context: context,
      isScrollControlled: true,
      builder: (c) => MonsterAttackModal(actions: actions, targets: targets),
    );
    if (plan == null) return;

    for (final id in plan.targetIds) {
      final t = _ctrl.combatants.firstWhere((c) => c.id == id);
      if (t.isDefeated) continue;
      final roll = Random().nextInt(20) + 1;
      final total = roll + (plan.action.attackBonus ?? 0);
      final hit = total >= t.armorClass;
      int dmg = 0;
      if (hit) {
        dmg = plan.action.damage.isEmpty ? 1 : plan.action.damage.fold(0, (s, d) => s + RollDiceService.rollDiceExpression(d.damageDice));
        if (dmg == 0) dmg = 1;
        _ctrl.applyDamage(t.id, dmg);
      }
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
        builder: (c) => MonsterAttackResultModal(
          attackerName: m.name,
          target: t,
          action: plan.action,
          roll: roll,
          total: total,
          hit: hit,
          damage: dmg,
        ),
      );
    }
  }

  Future<void> _editHp(Combatant c) async {
    final hp = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CombatantHpModal(combatant: c),
    );
    if (hp != null) setState(() => c.currentHp = hp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Combate'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: Navigator.of(context).pop),
      ),
      body: ListenableBuilder(
        listenable: _ctrl,
        builder: (_, __) {
          final current = _ctrl.currentCombatant;
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text('Rodada ${_ctrl.round}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(current.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${current.type.label} | Iniciativa ${current.initiative}'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemCount: _ctrl.displayOrder.length,
                  itemBuilder: (_, i) {
                    final c = _ctrl.displayOrder[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c.isDefeated ? Colors.grey : (c.type == CombatantType.player ? Colors.blue : Colors.purple),
                          backgroundImage: c.type == CombatantType.monster && c.imageUrl != null ? NetworkImage(c.imageUrl!) : null,
                          child: c.type == CombatantType.player ? Text(c.name[0]) : null,
                        ),
                        title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.isDefeated
                                ? 'Derrotado'
                                : 'HP: ${c.currentHp}/${c.maxHp} | CA: ${c.armorClass} | Iniciativa: ${c.initiative}',
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: c.currentHp / c.maxHp, // valor entre 0 e 1
                              minHeight: 8,
                              backgroundColor: Colors.black,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.green)),
                            ),
                          
                        ],
                      ),
                 
                        trailing: IconButton(icon: const Icon(Icons.healing), onPressed: () => _editHp(c)),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: current.type == CombatantType.player ? _playerAttack : _monsterAttack,
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Atacar'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _ctrl.advanceTurn,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('Próximo turno'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}