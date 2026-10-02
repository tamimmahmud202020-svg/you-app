import 'dart:convert';

import '../models/study_record.dart';

/// Represents a single MCQ question returned by AI.
class AiQuestion {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String explanation;
  final String subject;
  final String topic;
  final String difficulty;

  const AiQuestion({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.subject,
    required this.topic,
    required this.difficulty,
  });

  Map<String, dynamic> toJson() => {
        'question': question,
        'options': options,
        'correctAnswer': correctAnswer,
        'explanation': explanation,
        'subject': subject,
        'topic': topic,
        'difficulty': difficulty,
      };
}

/// Represents a complete AI-generated exam.
class AiExam {
  final String examTitle;
  final List<AiQuestion> questions;

  const AiExam({
    required this.examTitle,
    required this.questions,
  });

  int get length => questions.length;
}

class JsonValidator {
  JsonValidator._();

  /// Clean up any markdown fences the AI might add around JSON.
  static String _stripCodeFences(String raw) {
    var text = raw.trim();
    // Remove ```json ... ``` or ``` ... ```
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      if (firstNewline != -1) {
        text = text.substring(firstNewline + 1);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
    }
    return text.trim();
  }

  /// Parse and validate a study-plan/exam JSON response from AI.
  /// Throws [FormatException] if invalid.
  static AiExam parseExam(String rawText) {
    final clean = _stripCodeFences(rawText);
    final dynamic decoded;
    try {
      decoded = jsonDecode(clean);
    } catch (e) {
      throw FormatException('AI did not return valid JSON: $e');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('AI response is not a JSON object.');
    }

    final title = (decoded['examTitle'] as String?)?.trim() ?? 'Monthly Exam';
    final rawQuestions = decoded['questions'];

    if (rawQuestions is! List || rawQuestions.isEmpty) {
      throw const FormatException('AI response has no questions.');
    }

    final questions = <AiQuestion>[];
    for (var i = 0; i < rawQuestions.length; i++) {
      final q = rawQuestions[i];
      if (q is! Map<String, dynamic>) {
        throw FormatException('Question $i is not an object.');
      }

      final questionText = (q['question'] as String?)?.trim() ?? '';
      if (questionText.isEmpty) {
        throw FormatException('Question $i has no question text.');
      }

      final rawOptions = q['options'];
      if (rawOptions is! List || rawOptions.length != 4) {
        throw FormatException('Question $i must have exactly 4 options.');
      }
      final options = rawOptions.map((o) => o.toString().trim()).toList();
      if (options.any((o) => o.isEmpty)) {
        throw FormatException('Question $i has an empty option.');
      }

      final correct = q['correctAnswer'];
      if (correct is! int || correct < 0 || correct > 3) {
        throw FormatException(
            'Question $i correctAnswer must be 0, 1, 2, or 3.');
      }

      final explanation = (q['explanation'] as String?)?.trim() ?? '';
      final subject = (q['subject'] as String?)?.trim() ?? 'Other';
      final topic = (q['topic'] as String?)?.trim() ?? 'General';
      final difficulty =
          (q['difficulty'] as String?)?.trim().toLowerCase() ?? 'medium';

      questions.add(AiQuestion(
        question: questionText,
        options: options,
        correctAnswer: correct,
        explanation: explanation,
        subject: subject,
        topic: topic,
        difficulty: difficulty,
      ));
    }

    return AiExam(examTitle: title, questions: questions);
  }

  /// Build the JSON skeleton prompt fragment from study records.
  static String buildStudyContext(List<StudyRecord> records) {
    if (records.isEmpty) return 'No study records available.';

    final buffer = StringBuffer();
    final bySubject = <String, Set<String>>{};
    for (final r in records) {
      bySubject.putIfAbsent(r.subject, () => <String>{}).add(r.topic);
    }

    bySubject.forEach((subject, topics) {
      buffer.writeln('- $subject:');
      for (final t in topics) {
        buffer.writeln('   • $t');
      }
    });
    return buffer.toString();
  }
}