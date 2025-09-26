// lib/gemini_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'gemini_service.dart'; // Import the new service

class MyGeminiPage extends StatefulWidget {
  const MyGeminiPage({super.key, required this.title});

  final String title;

  @override
  State<MyGeminiPage> createState() => _MyGeminiPageState();
}

class _MyGeminiPageState extends State<MyGeminiPage> {
  final TextEditingController _promptController = TextEditingController();
  final GeminiService _geminiService = GeminiService(); // Create an instance of the service
  String _geminiResponse = '';
  bool _isLoading = false;

  // This method now calls our service
  Future<void> _callGeminiAI() async {
    final prompt = _promptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _geminiResponse = '';
    });

    String response;
    // Simple check to see if the prompt is a URL for a JPEG image
    if (prompt.startsWith('http')) {
      // if (prompt.startsWith('http') && (prompt.endsWith('.jpg') || prompt.endsWith('.jpeg'))) {
      response = await _geminiService.detectPet(prompt);
      // response = await _geminiService.describeImage(prompt);
    } else {
      response = await _geminiService.getAsciiArt(prompt);
    }

    setState(() {
      _isLoading = false;
      _geminiResponse = response;
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Theme.of(context).colorScheme.inversePrimary, title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Paste an URL about a Pet image', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _promptController,
              decoration: const InputDecoration(hintText: 'Enter image URL', border: OutlineInputBorder()),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _callGeminiAI,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Ask Gemini'),
            ),
            const SizedBox(height: 24),
            if (_promptController.text.trim().startsWith('http'))
              CachedNetworkImage(imageUrl: _promptController.text.trim(), height: 200, fit: BoxFit.fitHeight),
            const SizedBox(height: 24),
            const Text('Gemini Analysis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoading
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [CircularProgressIndicator(), SizedBox(height: 16), Text('Thinking...')],
                        ),
                      )
                    : SingleChildScrollView(
                        child: SelectableText(
                          _geminiResponse.isEmpty ? 'Gemini\'s analysis will appear here' : _geminiResponse,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
