import 'package:flutter/material.dart';
import '../models/combatant.dart';

class CombatantHpModal extends StatefulWidget {
  const CombatantHpModal({super.key, required this.combatant});
  final Combatant combatant;

  @override
  State<CombatantHpModal> createState() => _CombatantHpModalState();
}

class _CombatantHpModalState extends State<CombatantHpModal> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.combatant.currentHp.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
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
          Text('Editar HP de ${widget.combatant.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'HP (máx: ${widget.combatant.maxHp})',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final hp = int.tryParse(_controller.text) ?? widget.combatant.currentHp;
              Navigator.pop(context, hp.clamp(0, widget.combatant.maxHp));
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}