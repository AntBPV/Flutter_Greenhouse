import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiConfig {
  static String get apiKey => dotenv.env["GEMINI_API_KEY"] ?? "";

  static const String modelName = "gemini-2.0-flash";

  static GenerativeModel model() {
    if (apiKey.isEmpty) {
      throw Exception(
        "❌ No se encontró la variable GEMINI_API_KEY en el archivo .env",
      );
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      ],
    );
  }
}
