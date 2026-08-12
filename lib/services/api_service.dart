import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator to connect to localhost, or physical device IP
  static const String baseUrl =
      'https://flick-smitten-unstamped.ngrok-free.dev';

  Future<QuizResponse> generateQuiz({
    required List<int> fileBytes,
    required String fileName,
    required int numQuestions,
    required String difficulty,
    required String coLevel,
    required int startPage,
    required int endPage,
    required bool isMcq,
  }) async {
    final String endpoint = isMcq ? '/generate-mcq' : '/generate-fill';
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest('POST', uri);

    request.fields['num_questions'] = numQuestions.toString();
    request.fields['difficulty'] = difficulty;
    request.fields['co_level'] = coLevel;
    request.fields['start_page'] = startPage.toString();
    request.fields['end_page'] = endPage.toString();

    request.files.add(
      http.MultipartFile.fromBytes(
        'pdf',
        fileBytes,
        filename: fileName,
      ),
    );

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return QuizResponse.fromJson(data);
      } else {
        String errorMsg = 'Failed to generate quiz';

        try {
          final errorData = json.decode(response.body);

          if (errorData['detail'] != null) {
            errorMsg = errorData['detail'];
          }
        } catch (_) {}

        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}