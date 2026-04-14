import 'package:flutter/material.dart';
import '../models/combatant.dart';
import '../models/monster.dart';

class MonsterAttackPlan {
  MonsterAttackPlan({required this.action, required this.targetIds});
  final MonsterAction action;
  final List<String> targetIds;
}

class MonsterAttackModal extends StatefulWidget {
  const MonsterAttackModal({super.key, required this.actions, required this.targets});
  final List<MonsterAction> actions;
  final List<Combatant> targets;

  @override
  State<MonsterAttackModal> createState() => _MonsterAttackModalState();
}

class _MonsterAttackModalState extends State<MonsterAttackModal> {
  late MonsterAction _action;
  final _targetIds = <String>{};

  @override
  void initState() {
    super.initState();
    _action = widget.actions.first;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text('Ataque', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<MonsterAction>(
            value: _action,
            items: widget.actions.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
            onChanged: (a) => setState(() => _action = a!),
            decoration: const InputDecoration(labelText: 'Ação'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(_action.desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ),
          const Divider(),
          const Text('Alvos:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...widget.targets.map((t) => CheckboxListTile(
            title: Text(t.name),
            subtitle: Text('CA: ${t.armorClass} | HP: ${t.currentHp}'),
            value: _targetIds.contains(t.id),
            onChanged: (c) => setState(() => c! ? _targetIds.add(t.id) : _targetIds.remove(t.id)),
          )),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _targetIds.isEmpty ? null : () {
              Navigator.pop(context, MonsterAttackPlan(action: _action, targetIds: _targetIds.toList()));
            },
            child: const Text('Executar'),
          ),
        ],
      ),
    );
  }
}