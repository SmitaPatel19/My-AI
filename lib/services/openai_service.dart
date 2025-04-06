import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:allen/services/secrets.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  final List<Map<String, String>> conversationHistory = [];
  final int _maxHistoryLength = 10;
  final _rateLimiter = RateLimiter(5, Duration(minutes: 1)); // 5 requests per minute
  static final _responseCache = <String, String>{};

  void clearConversationHistory() {
    conversationHistory.clear();
  }

  Future<String> handleUserPrompt(String prompt) async {
    try {
      await _rateLimiter.throttle();

      if (_responseCache.containsKey(prompt)) {
        return _responseCache[prompt]!;
      }

      final isArt = await _isArtPrompt(prompt);
      final response = isArt ? await _generateImage(prompt) : await _generateText(prompt);

      _responseCache[prompt] = response;
      return response;
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<bool> _isArtPrompt(String prompt) async {
    try {
      final response = await _makeApiRequest(
        'chat/completions',
        {
          "model": "gpt-4o",
          "messages": [
            {
              'role': 'system',
              'content': 'Determine if the user wants to generate an image. Respond only with "yes" or "no".',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          "max_tokens": 1,
        },
      );

      return response.toLowerCase().contains('yes');
    } catch (e) {
      return false;
    }
  }

  Future<String> _generateText(String prompt) async {
    _addToHistory(role: 'user', content: prompt);

    final response = await _makeApiRequest(
      'chat/completions',
      {
        "model": "gpt-4o",
        "messages": conversationHistory,
        "temperature": 0.7,
      },
    );

    _addToHistory(role: 'assistant', content: response);
    return response;
  }

  Future<String> _generateImage(String prompt) async {
    try {
      _addToHistory(role: 'user', content: prompt);

      final response = await _makeApiRequest(
        'images/generations',
        {
          "model": "dall-e-3",
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'response_format': 'url',
        },
      );

      _addToHistory(role: 'assistant', content: response);
      return response;
    } catch (e) {
      return 'error'; // Return a special string for error cases
    }
  }

  Future<String> _makeApiRequest(
      String endpoint,
      Map<String, dynamic> body, {
        bool isImageGeneration = false,
      }) async {
    final url = Uri.parse('https://api.openai.com/v1/$endpoint');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $openAIAPIKey',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (isImageGeneration) {
        return jsonResponse['data'][0]['url'].toString().trim();
      } else {
        return jsonResponse['choices'][0]['message']['content'].toString().trim();
      }
    } else {
      throw ApiException(
        response.statusCode,
        response.body,
      );
    }
  }

  void _addToHistory({required String role, required String content}) {
    conversationHistory.add({'role': role, 'content': content, });
    if (conversationHistory.length > _maxHistoryLength) {
      conversationHistory.removeAt(0);
    }
  }

  String _handleError(dynamic e) {
    if (e is ApiException) {
      return 'API Error (${e.statusCode}): ${e.message}';
    } else if (e is RateLimitException) {
      return 'Please wait before making another request';
    }
    return 'An error occurred: ${e.toString()}';
  }

  void clearConversation() {
    conversationHistory.clear();
    _responseCache.clear();
  }
}

class RateLimiter {
  final int maxRequests;
  final Duration period;
  final Queue<DateTime> _requestTimes = Queue();

  RateLimiter(this.maxRequests, this.period);

  Future<void> throttle() async {
    final now = DateTime.now();
    _requestTimes.removeWhere((time) => now.difference(time) > period);

    if (_requestTimes.length >= maxRequests) {
      throw RateLimitException();
    }

    _requestTimes.add(now);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, String responseBody)
      : message = jsonDecode(responseBody)['error']['message'] ?? 'Unknown error';

  @override
  String toString() => 'API Exception: $statusCode - $message';
}

class RateLimitException implements Exception {
  final String message = 'Rate limit exceeded';
}