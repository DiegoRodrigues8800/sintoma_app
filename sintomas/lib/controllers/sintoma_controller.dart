import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/sintoma.dart';

class SintomaController {
  final String baseUrl = "https://sintoma-844ec-default-rtdb.firebaseio.com/";
  final List<Sintoma> _items = [];

  Future<List<Sintoma>> getItems() async {
    final response = await http.get(Uri.parse('$baseUrl/items.json'));
    _items.clear();
    if (response.statusCode == 200) {
      dynamic decodedBody = jsonDecode(response.body);
      if (decodedBody != null && decodedBody is Map<String, dynamic>) {
        decodedBody.forEach((sintomaId, sintomaData) {
          _items.add(Sintoma(
            id: sintomaId,
            sintoma: sintomaData['sintoma'],
            intensidade: sintomaData['intensidade'],
            data: sintomaData['data'],
          ));
        });
        return _items;
      } else {
        return [];
      }
    } else {
      throw Exception('Erro ao obter os dados: ${response.statusCode}');
    }
  }

  Future<void> addItem(Sintoma item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/items.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao adicionar item");
    }
  }

  Future<void> updateItem(Sintoma item) async {
    final response = await http.put(
      Uri.parse('$baseUrl/items/${item.id}.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(item.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao atualizar item");
    }
  }

  Future<void> deleteItem(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/items/$id.json'),
    );

    if (response.statusCode != 200) {
      throw Exception("Erro ao excluir item");
    }
  }
}
