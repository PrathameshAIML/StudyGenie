class QuizQuestion {
  final String question;
  final String answer;
  final List<String>? options;

  QuizQuestion({
    required this.question,
    required this.answer,
    this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      options: json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'answer': answer,
      if (options != null) 'options': options,
    };
  }
}

class QuizResponse {
  final List<QuizQuestion> questions;
  final String pdfBase64;
  final String filename;

  QuizResponse({
    required this.questions,
    required this.pdfBase64,
    required this.filename,
  });

  factory QuizResponse.fromJson(Map<String, dynamic> json) {
    return QuizResponse(
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
      pdfBase64: json['pdf_base64'] ?? '',
      filename: json['filename'] ?? '',
    );
  }
}
