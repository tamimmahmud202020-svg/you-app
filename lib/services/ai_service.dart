import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/errors/ai_exception.dart';
import '../models/ai_config.dart';
import '../models/study_record.dart';
import '../utils/json_validator.dart';

class AiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  final AiConfig config;

  AiService(this.config);

  /// Test the connection with a tiny prompt.
  /// Returns true if successful, throws [AiException] otherwise.
  Future<bool> testConnection() async {
    if (!config.isReady) {
      throw AiException.notConfigured();
    }

    try {
      final response = await _sendPrompt(
        'Reply with exactly: OK',
        maxTokens: 20,
        expectJson: false,
      );
      return response.trim().toUpperCase().contains('OK');
    } on AiException {
      rethrow;
    } catch (e) {
      throw AiException.unknown(e.toString());
    }
  }

  /// Generate an exam based on the study history.
  Future<AiExam> generateExam({
    required List<StudyRecord> studyHistory,
    int questionCount = 20,
    String difficulty = 'medium',
    String? customInstruction,
  }) async {
    if (!config.isReady) {
      throw AiException.notConfigured();
    }
    if (studyHistory.isEmpty) {
      throw AiException.unknown(
          'No study records. Add some study sessions first.');
    }

    final context = JsonValidator.buildStudyContext(studyHistory);

    final prompt = '''
You are an expert BCS exam question setter for Bangladesh.
Based on the student's study history below, generate $questionCount multiple-choice questions (MCQs).

STUDY HISTORY:
$context

REQUIREMENTS:
- Difficulty: $difficulty
- Each question must have EXACTLY 4 options
- Only ONE correct option
- The 'correctAnswer' field must be the index (0, 1, 2, or 3)
- Include a short explanation
- The 'subject' should match one from the study history
- The 'topic' should be a specific topic from the study history
- Questions should be factual, exam-oriented, and cover different topics

${customInstruction ?? ''}

Return ONLY valid JSON with this exact structure (no markdown, no extra text):
{
  "examTitle": "Monthly Exam",
  "questions": [
    {
      "question": "Question text here?",
      "options": ["Option A", "Option B", "Option C", "Option D"],
      "correctAnswer": 0,
      "explanation": "Short explanation here.",
      "subject": "Bangladesh Affairs",
      "topic": "Liberation War",
      "difficulty": "$difficulty"
    }
  ]
}
''';

    try {
      final rawText = await _sendPrompt(
        prompt,
        maxTokens: 8192,
        expectJson: true,
      );
      return JsonValidator.parseExam(rawText);
    } on AiException {
      rethrow;
    } on FormatException catch (e) {
      throw AiException.invalidResponse(e.toString());
    } catch (e) {
      throw AiException.unknown(e.toString());
    }
  }

  /// Ask a free-form question. Returns plain text answer.
  Future<String> askQuestion(String question) async {
    if (!config.isReady) {
      throw AiException.notConfigured();
    }
    return _sendPrompt(
      'You are a helpful BCS exam tutor for Bangladesh. '
      'Answer clearly and concisely in the same language as the question.\n\n'
      'Question: $question',
      maxTokens: 1024,
      expectJson: false,
    );
  }

  /// Core method: sends a prompt to Gemini and returns the response text.
  Future<String> _sendPrompt(
    String prompt, {
    int maxTokens = 2048,
    bool expectJson = false,
  }) async {
    // API key is passed via header (x-goog-api-key) instead of query param,
    // because newer "AQ.Ab8..." style keys require header authentication.
    final uri = Uri.parse(
      '$_baseUrl/${config.model}:generateContent',
    );

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': maxTokens,
        if (expectJson) 'responseMimeType': 'application/json',
      },
    });

    http.Response response;
    try {
      response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': config.apiKey ?? '',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException {
      throw AiException.noInternet();
    } on TimeoutException {
      throw AiException.timeout();
    } catch (e) {
      throw AiException.unknown(e.toString());
    }

    if (response.statusCode == 400) {
      throw AiException.invalidApiKey();
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw AiException.invalidApiKey();
    }
    if (response.statusCode == 404) {
      throw AiException.serverError(404);
    }
    if (response.statusCode == 429) {
      throw AiException.rateLimitExceeded();
    }
    if (response.statusCode >= 500) {
      throw AiException.serverError(response.statusCode);
    }
    if (response.statusCode != 200) {
      throw AiException.serverError(response.statusCode);
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw AiException.invalidResponse('Could not decode response body.');
    }

    final candidates = decoded['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw AiException.invalidResponse('No candidates in response.');
    }
    final first = candidates.first;
    if (first is! Map<String, dynamic>) {
      throw AiException.invalidResponse('Bad candidate structure.');
    }
    final content = first['content'];
    if (content is! Map<String, dynamic>) {
      throw AiException.invalidResponse('No content in candidate.');
    }
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw AiException.invalidResponse('No parts in content.');
    }
    final firstPart = parts.first;
    if (firstPart is! Map<String, dynamic>) {
      throw AiException.invalidResponse('Bad part structure.');
    }
    final text = firstPart['text'];
    if (text is! String || text.trim().isEmpty) {
      throw AiException.invalidResponse('Empty text in response.');
    }

    return text.trim();
  }
}