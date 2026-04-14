import 'dart:math';

class DataRoll {
  int roll;
  int total;

  DataRoll({required this.roll, required this.total});

}

class RollDiceService {
   static final random = Random();
   static int rollDiceExpression(String? expression) {

    if (expression == null || expression.trim().isEmpty) {
      return 0;
    }

    final sanitized = expression.replaceAll(' ', '');
    final tokenPattern = RegExp(r'([+-]?\d*d?\d+)');
    final tokens = tokenPattern
        .allMatches(sanitized)
        .map((match) => match.group(0)!)
        .toList();

    if (tokens.isEmpty) {
      return int.tryParse(sanitized) ?? 0;
    }

    var total = 0;
    for (final token in tokens) {
      final sign = token.startsWith('-') ? -1 : 1;
      final normalized = token.startsWith(RegExp(r'[+-]'))
          ? token.substring(1)
          : token;

      if (!normalized.contains('d')) {
        total += sign * (int.tryParse(normalized) ?? 0);
        continue;
      }

      final parts = normalized.split('d');
      final diceCount = (int.tryParse(parts[0]) ?? 1).clamp(1, 100);
      final diceSides = int.tryParse(parts[1]) ?? 0;
      if (diceSides <= 0) {
        continue;
      }

      for (var i = 0; i < diceCount; i++) {
        total += sign * (random.nextInt(diceSides) + 1);
      }
    }

    return total;
  }

  static DataRoll combatRoll(int? attackBonus) {
    final roll = random.nextInt(20) + 1;
    final total = roll + (attackBonus ?? 0);
    return DataRoll(roll: roll, total: total);
  }

}