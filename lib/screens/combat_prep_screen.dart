import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/combatant.dart';
import '../models/monster.dart';
import '../models/player.dart';
import '../services/api_service.dart';
import 'combat_turn_screen.dart';

class CombatPrepScreen extends StatefulWidget {
  const CombatPrepScreen({super.key});

  @override
  State<CombatPrepScreen> createState() => _CombatPrepScreenState();
}

class _CombatPrepScreenState extends State<CombatPrepScreen> {
  final _api = ApiService();
  final _rand = Random();

  late List<Player> _players;
  final _selectedPlayers = <String, int>{};
  late List<Monster> _monsters;
  Monster? _selectedMonster;
  Monster? _monsterPreview;
  final _selectedMonsters = <_M>[];
  final _cache = <String, Monster>{};

  bool _loading = true;
  bool _loadingMonsters = false;
  bool _loadingPreview = false;
  bool _starting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('players') ?? [];
      _players = stored.map((e) => Player.fromJson(jsonDecode(e))).toList();
      await _loadMonsters();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMonsters() async {
    setState(() {
      _loadingMonsters = true;
      _error = null;
    });
    try {
      _monsters = await _api.fetchMonsters();
      if (_monsters.isNotEmpty) {
        _selectedMonster = _monsters[0];
        await _loadPreview(_selectedMonster!);
      }
    } catch (e) {
      _error = 'Erro ao carregar monstros';
    } finally {
      if (mounted) setState(() => _loadingMonsters = false);
    }
  }

  Future<void> _loadPreview(Monster m) async {
    if (_cache.containsKey(m.index)) {
      if (mounted) setState(() => _monsterPreview = _cache[m.index]);
      return;
    }
    setState(() => _loadingPreview = true);
    try {
      final details = await _api.fetchMonsterDetails(m.index);
      _cache[m.index] = details;
      if (mounted && _selectedMonster?.index == m.index) {
        setState(() => _monsterPreview = details);
      }
    } finally {
      if (mounted) setState(() => _loadingPreview = false);
    }
  }

  Future<void> _togglePlayer(Player p, bool selected) async {
    if (!selected) {
      setState(() => _selectedPlayers.remove(p.name));
      return;
    }
    final init = await _initiative(p);
    if (init != null) setState(() => _selectedPlayers[p.name] = init);
  }

  Future<int?> _initiative(Player p) async {
    int? init;
    final ctrl = TextEditingController();
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (_, setState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 16, right: 16, top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Iniciativa de ${p.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Bônus: ${p.bonusInitiative}'),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  final roll = _rand.nextInt(20) + 1;
                  setState(() {
                    init = roll + p.bonusInitiative;
                    ctrl.text = init.toString();
                  });
                },
                icon: const Icon(Icons.casino),
                label: const Text('Rolar'),
              ),
              const SizedBox(height: 12),
              TextField(controller: ctrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Resultado')),
              const SizedBox(height: 12),
              if (init != null) Text('Iniciativa: $init', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: init == null ? null : () => Navigator.pop(c, init), child: const Text('Confirmar')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _start() async {
    if (_starting || (_selectedPlayers.isEmpty && _selectedMonsters.isEmpty)) return;

    setState(() => _starting = true);
    try {
      final players = _players
          .where((p) => _selectedPlayers.containsKey(p.name))
          .map((p) => Combatant(
                id: 'p-${p.name}',
                name: p.name,
                initiative: _selectedPlayers[p.name]!,
                type: CombatantType.player,
                armorClass: p.cA,
                maxHp: p.maxHp,
                currentHp: p.currentHp,
              ))
          .toList();

      final monsters = <Combatant>[];
      for (final m in _selectedMonsters) {
        final details = _cache[m.monster.index] ?? await _api.fetchMonsterDetails(m.monster.index);
        _cache[m.monster.index] = details;
        monsters.add(Combatant(
          id: m.id,
          name: details.name,
          initiative: _rand.nextInt(20) + 1,
          type: CombatantType.monster,
          armorClass: details.armorClass ?? 10,
          maxHp: details.hitPoints ?? 1,
          currentHp: details.hitPoints ?? 1,
          monsterActions: details.actions,
          imageUrl: details.imageUrl,
        ));
      }

      final all = [...players, ...monsters];
      all.sort((a, b) => b.initiative.compareTo(a.initiative) != 0 ? b.initiative.compareTo(a.initiative) : a.name.compareTo(b.name));

      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => CombatTurnScreen(combatants: all)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao iniciar combate')));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Preparar Combate')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          const Text('Jogadores', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_players.isEmpty)
            const Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Sem jogadores')))
          else
            ..._players.map((p) {
              final sel = _selectedPlayers.containsKey(p.name);
              return Card(
                child: CheckboxListTile(
                  value: sel,
                  title: Text(p.name),
                  subtitle: Text('HP: ${p.maxHp} | CA: ${p.cA} | Iniciativa: ${_selectedPlayers[p.name] ?? "-"}'),
                  onChanged: (v) => _togglePlayer(p, v ?? false),
                ),
              );
            }),
          const SizedBox(height: 24),
          const Text('Monstros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_loadingMonsters)
            const Card(child: Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())))
          else if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Text(_error!),
                    ElevatedButton(onPressed: _loadMonsters, child: const Text('Tentar novamente')),
                  ],
                ),
              ),
            )
          else ...[
            DropdownButtonFormField<Monster>(
              value: _selectedMonster,
              items: _monsters.map((m) => DropdownMenuItem(value: m, child: Text(m.name))).toList(),
              onChanged: (m) {
                if (m != null) {
                  setState(() => _selectedMonster = m);
                  _loadPreview(m);
                }
              },
              decoration: const InputDecoration(labelText: 'Escolha um monstro'),
            ),
            const SizedBox(height: 12),
            if (_loadingPreview)
              const Card(child: Padding(padding: EdgeInsets.all(12), child: Center(child: CircularProgressIndicator())))
            else if (_monsterPreview != null) ...[
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_monsterPreview!.imageUrl != null)
                      SizedBox(height: 150, width: double.infinity, child: Image.network(_monsterPreview!.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey)))
                    else
                      SizedBox(height: 150, child: Container(color: Colors.grey, child: const Icon(Icons.image_not_supported))),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_monsterPreview!.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('HP: ${_monsterPreview!.hitPoints} | CA: ${_monsterPreview!.armorClass} | CR: ${_monsterPreview!.challengeRating}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                if (_selectedMonster == null) return;
                setState(() => _selectedMonsters.add(_M('${_selectedMonster!.index}-${DateTime.now().microsecondsSinceEpoch}', _monsterPreview ?? _selectedMonster!)));
              },
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
            const SizedBox(height: 12),
            if (_selectedMonsters.isEmpty)
              const Text('Nenhum monstro')
            else
              ..._selectedMonsters.asMap().entries.map((e) {
                final m = e.value;
                return Card(
                  child: ListTile(
                    title: Text(m.monster.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('HP: ${m.monster.hitPoints} | CA: ${m.monster.armorClass} | CR: ${m.monster.challengeRating}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(() => _selectedMonsters.removeAt(e.key))
                    )
                  ),
                );
              }),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: (_selectedPlayers.isNotEmpty || _selectedMonsters.isNotEmpty) && !_starting ? _start : null,
            icon: _starting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.play_arrow),
            label: Text(_starting ? 'Iniciando...' : 'Iniciar'),
          ),
        ),
      ),
    );
  }
}

class _M {
  _M(this.id, this.monster);
  final String id;
  final Monster monster;
}
