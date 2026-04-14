import 'package:flutter/material.dart';
import '../models/combatant.dart';

class PlayerDamageResult {
  PlayerDamageResult({required this.targetId, required this.damage});
  final String targetId;
  final int damage;
}

class PlayerDamageModal extends StatefulWidget {
  const PlayerDamageModal({
    super.key,
    required this.attackerName,
    required this.livingMonsters,
  });
  final String attackerName;
  final List<Combatant> livingMonsters;

  @override
  State<PlayerDamageModal> createState() => _PlayerDamageModalState();
}

class _PlayerDamageModalState extends State<PlayerDamageModal> {
  final _damageController = TextEditingController();
  late Combatant _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.livingMonsters.first;
  }

  @override
  void dispose() {
    _damageController.dispose();
    super.dispose();
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Dano de ${widget.attackerName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<Combatant>(
            value: _selected,
            items: widget.livingMonsters
                .map((m) => DropdownMenuItem(value: m, child: Text(m.name)))
                .toList(),
            onChanged: (v) => setState(() => _selected = v!),
            decoration: const InputDecoration(labelText: 'Alvo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _damageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dano'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final damage = int.tryParse(_damageController.text);
              if (damage != null && damage > 0) {
                Navigator.pop(context, PlayerDamageResult(targetId: _selected.id, damage: damage));
              }
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }
}