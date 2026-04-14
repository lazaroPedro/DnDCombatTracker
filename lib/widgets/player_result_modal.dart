import 'package:flutter/material.dart';
import '../../models/combatant.dart';


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
  Combatant? _selectedMonster;

  @override
  void initState() {
    super.initState();
    if (widget.livingMonsters.isNotEmpty) {
      _selectedMonster = widget.livingMonsters.first;
    }
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
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Dano de ${widget.attackerName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Combatant>(
            initialValue: _selectedMonster,
            items: widget.livingMonsters.map((monster) {
              return DropdownMenuItem<Combatant>(
                value: monster,
                child: Text(monster.name),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedMonster = value),
            decoration: const InputDecoration(
              labelText: 'Monstro alvo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _damageController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Dano causado'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final damage = int.tryParse(_damageController.text.trim());
              if (_selectedMonster == null || damage == null || damage <= 0) return;

              // Retorna o resultado empacotado para quem abriu o modal
              Navigator.pop(
                context,
                PlayerDamageResult(targetId: _selectedMonster!.id, damage: damage),
              );
            },
            child: const Text('APLICAR DANO'),
          ),
        ],
      ),
    );
  }
}