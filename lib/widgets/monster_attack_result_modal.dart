import 'package:flutter/material.dart';
import '../models/combatant.dart';
import '../models/monster.dart';

class MonsterAttackResultModal extends StatelessWidget {
  const MonsterAttackResultModal({
    super.key,
    required this.attackerName,
    required this.target,
    required this.action,
    required this.roll,
    required this.total,
    required this.hit,
    required this.damage,
  });

  final String attackerName;
  final Combatant target;
  final MonsterAction action;
  final int roll;
  final int total;
  final bool hit;
  final int damage;

  @override
 Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          '$attackerName usou ${action.name}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 16),


        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: hit
              ? Colors.green.withOpacity(0.08)
              : Colors.orange.withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      target.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Rolagem
                Row(
                  children: [
                    const Icon(Icons.casino, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '$roll + ${action.attackBonus ?? 0} = $total',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.shield, size: 18),
                    const SizedBox(width: 6),
                    Text('CA: ${target.armorClass}'),
                  ],
                ),


                  const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      hit ? Icons.check_circle : Icons.cancel,
                      color: hit ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hit ? 'Acertou! Dano: $damage' : 'Errou.',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 🔹 Botão
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ),
      ],
    ),
  );
}
}