import 'dart:async';
import 'dart:math';

class AiChatService {
  // TODO: Replace with actual OpenAI API implementation when API key is provided
  final String? apiKey;

  AiChatService({this.apiKey});

  Future<String> getResponse(String userMessage) async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    if (apiKey != null && apiKey!.isNotEmpty) {
      // Placeholder for real OpenAI call
      // return _callOpenAI(userMessage);
    }

    // Mock responses for now
    final mockResponses = [
      "I can certainly help you with that! Based on your home data, I recommend checking the HVAC filters soon.",
      "Your monthly subscription spending is currently \$45.00 across 3 active services.",
      "The property deed for your home is securely stored in your Digital Vault.",
      "I've analyzed your maintenance calendar. You have 2 upcoming tasks this week.",
      "That's a great question! Regular maintenance can reduce your long-term home repair costs by up to 30%.",
    ];

    return mockResponses[Random().nextInt(mockResponses.length)];
  }
}
