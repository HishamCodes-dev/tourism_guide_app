import 'dart:convert';
import 'package:http/http.dart' as http;

class WikipediaService {
  static Future<Map<String, dynamic>?> fetchAttractionInfo(String wikiKey) async {
    final formattedKey = wikiKey.trim().replaceAll(' ', '_');
    final url = Uri.parse(
        'https://en.wikipedia.org/api/rest_v1/page/summary/$formattedKey');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'title': data['title'] ?? wikiKey,
          'description': data['extract'] ?? 'No description available from Wikipedia.',
          'image': data['thumbnail'] != null ? data['thumbnail']['source'] : null,
        };
      }
    } catch (_) {}
    return null;
  }
}
