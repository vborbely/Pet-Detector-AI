// lib/gemini_service.dart
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  final model = FirebaseAI.googleAI().generativeModel(
    model: 'gemini-2.5-flash',
    systemInstruction: Content.system(
      'You are an ASCII art converter. Respond with only the ASCII art for the user\'s prompt, without any additional text or explanation.',
    ),
  );

  Future<String> generateContent(String prompt) async {
    try {
      final response = await model.generateContent([Content.text(prompt)]);
      return response.text ?? 'No response received from Gemini.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
