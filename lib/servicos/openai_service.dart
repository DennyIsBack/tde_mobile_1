import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/ingrediente.dart';

class GoogleGenerativeAIService {
  final String apiKey;

  GoogleGenerativeAIService(this.apiKey);

  Future<List<Ingrediente>> gerarIngredientes(String nomeReceita, int receitaId) async {
    const String endpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

    final String prompt = '''
    Dado o nome de uma receita "$nomeReceita", gere uma lista de ingredientes necessários no seguinte formato JSON:
    [
      {"nome_ingrediente": "string", "quantidade": int}
    ]
    ''';

    final body = {
      'contents': [
        {
          'parts': [
            { 'text': prompt }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'candidateCount': 1,
        'maxOutputTokens': 200,
      },
    };

    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: { 'Content-Type': 'application/json; charset=utf-8' },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Erro na requisição: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final String rawText = data['candidates'][0]['content']['parts'][0]['text'] as String;

    final String cleanedJson = rawText.replaceAll('```json', '').replaceAll('```', '').trim();

    final List<dynamic> jsonIngredientes = jsonDecode(cleanedJson);

    return jsonIngredientes.map((json) {
      return Ingrediente(
        id: null,
        nomeIngrediente: json['nome_ingrediente'],
        quantidade: json['quantidade'],
        receitaId: receitaId,
      );
    }).toList();
  }
}