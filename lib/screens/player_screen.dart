import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

class PlayerFormScreen extends StatefulWidget {
  const PlayerFormScreen({super.key});

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  static const _key = 'players';
  final _players = <Player>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_key) ?? [];
    if (!mounted) return;
    setState(() {
      _players.clear();
      _players.addAll(stored.map((e) => Player.fromJson(jsonDecode(e))));
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _players.map((p) => jsonEncode(p.toJson())).toList());
  }

  void _openModal({Player? player, int? index}) async {
    final isEditing = player != null;
    final name = TextEditingController(text: player?.name ?? '');
    final bonus = TextEditingController(text: player?.bonusInitiative.toString() ?? '');
    final hp = TextEditingController(text: player?.maxHp.toString() ?? '');
    final ca = TextEditingController(text: player?.cA.toString() ?? '');

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEditing ? 'Editar Herói' : 'Novo Herói', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nome')),
            TextField(controller: bonus, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Bônus Iniciativa')),
            TextField(controller: hp, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'HP')),
            TextField(controller: ca, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'CA')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (name.text.isEmpty) return;
                final maxHp = int.tryParse(hp.text) ?? 0;
                final p = Player(
                  name: name.text.trim(),
                  bonusInitiative: int.tryParse(bonus.text) ?? 0,
                  maxHp: maxHp,
                  currentHp: isEditing ? player!.currentHp.clamp(0, maxHp) : maxHp,
                  cA: int.tryParse(ca.text) ?? 0,
                );
                setState(() {
                  if (isEditing && index != null) _players[index] = p;
                  else _players.add(p);
                });
                await _save();
                if (c.mounted) Navigator.pop(c);
              },
              child: Text(isEditing ? 'Editar' : 'Criar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _openModal, child: const Icon(Icons.add)),
      body: _players.isEmpty
          ? const Center(child: Text('Sem heróis'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _players.length,
              itemBuilder: (_, i) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(_players[i].name),
                  subtitle: Text('HP: ${_players[i].currentHp}/${_players[i].maxHp} | CA: ${_players[i].cA} | Init: ${_players[i].bonusInitiative}'),
                  onTap: () => _openModal(player: _players[i], index: i),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      _players.removeAt(i);
                      await _save();
                      setState(() {});
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
