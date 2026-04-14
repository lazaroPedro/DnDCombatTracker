import 'dart:convert';

import 'package:dnd_combat_tracker/models/monster.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "https://www.dnd5eapi.co/api/2014";

  Future<List<Monster>> fetchMonsters() async {
    final response = await http.get(Uri.parse('$baseUrl/monsters/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => Monster.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar monstros');
    }
  }

  Future<Monster> fetchMonsterDetails(String index) async {
    final response = await http.get(Uri.parse('$baseUrl/monsters/$index'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Monster.fromJson(data);
    } else {
      throw Exception('Falha ao carregar detalhes do monstro');
    }
  }
}
