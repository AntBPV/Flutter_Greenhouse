import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/gemini_config.dart';

class GeminiService {
  late final GenerativeModel _model;
  final List<Content> _history = [];

  GeminiService() {
    _model = GeminiConfig.model();
  }

  Future<String> sendMessage(String userMessage) async {
    try {
      final userContent = Content.text(userMessage);
      _history.add(userContent);

      final response = await _model.generateContent([..._history]);

      final text = response.text ?? "No pude generar una respuesta.";
      _history.add(Content.text(text));

      return text;
    } catch (e) {
      return "Ocurrió un error al procesar tu mensaje: $e";
    }
  }

  void clearChat() {
    _history.clear();
  }
}
