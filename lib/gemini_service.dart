// lib/gemini_service.dart
import 'dart:typed_data';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  late final GenerativeModel _asciiArtModel;
  late final GenerativeModel _multimodalModel;

  GeminiService() {
    // 1. Define a universal JSON schema for all responses
    final responseSchema = Schema.object(
      properties: {
        'title': Schema.string(description: "A creative, short title for the content."),
        'content': Schema.string(description: "The main generated content (e.g., ASCII art or image description)."),
      },
    );

    // 2. Create a single generation config to enforce JSON output
    final config = GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: responseSchema,
    );

    // 3. Initialize the ASCII art model with the config
    _asciiArtModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
          'You are an veterinarian. You must respond in JSON format that adheres to the provided schema, providing a title and the ASCII art as content.'),
      generationConfig: config,
    );

    // 4. Initialize the multimodal model with the same config
    _multimodalModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(
          'You are an veterinarian. You must respond in JSON format that adheres to the provided schema, providing: furColor, furLength, breed, age, gender.'),
      generationConfig: config,
    );
  }

  Future<String> getAsciiArt(String prompt) async {
    try {
      final response = await _asciiArtModel.generateContent([Content.text(prompt)]);
      // Return the raw JSON string
      return response.text ?? '{"error": "No response from model"}';
    } catch (e) {
      return '{"error": "${e.toString()}"}';
    }
  }

  Future<String> describeImage(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return '{"error": "Failed to load image from URL."}';
      }

      final Uint8List imageBytes = response.bodyBytes;

      final content = [
        Content.multi([
          // Update the text part to ask for JSON
          TextPart(
              'Describe this image in detail. You must respond in JSON format that adheres to the provided schema, providing a title and the description as content.'),
          InlineDataPart('image/jpeg', imageBytes),
        ])
      ];

      final modelResponse = await _multimodalModel.generateContent(content);
      // Return the raw JSON string
      return modelResponse.text ?? '{"error": "Could not describe the image."}';
    } catch (e) {
      return '{"error": "Error analyzing image: ${e.toString()}"}';
    }
  }

  Future<String> detectPet(String imageUrl) async {
    try {
      final http.Response response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        return '{"error": "Failed to load image from URL."}';
      }

      final Uint8List imageBytes = response.bodyBytes;

      final content = [
        Content.multi([
          // Update the text part to ask for JSON
          TextPart('Find a pet (Cat or Dog) in this image, if not found, give an empty JSON.'),
          TextPart(
              'You must respond in JSON format that adheres to the provided schema, providing: furColor, furLength, breed, age, gender'),
          InlineDataPart('image/jpeg', imageBytes),
        ])
      ];

      final modelResponse = await _multimodalModel.generateContent(content);
      // Return the raw JSON string
      return modelResponse.text ?? '{"error": "Could not find pet in the image."}';
    } catch (e) {
      return '{"error": "Error analyzing image: ${e.toString()}"}';
    }
  }
}