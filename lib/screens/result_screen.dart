import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';
import '../models/quiz_model.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final int score = data['score'] as int;
    final int total = data['total'] as int;

    final List<QuizQuestion> questions =
        data['questions'] as List<QuizQuestion>;

    final List<String> userAnswers =
        List<String>.from(data['userAnswers']);

    final double percentage = (score / total) * 100;

    String message;
    IconData icon;
    Color iconColor;

    if (percentage >= 80) {
      message = 'Excellent!';
      icon = Icons.emoji_events;
      iconColor = Colors.amber;
    } else if (percentage >= 50) {
      message = 'Good Job!';
      icon = Icons.thumb_up;
      iconColor = AppTheme.accentColor;
    } else {
      message = 'Keep Practicing!';
      icon = Icons.school;
      iconColor = Colors.blueAccent;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: iconColor,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        message,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(fontSize: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'You scored',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$score / $total',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final question = questions[index];

                    final userAnswer = userAnswers[index];
                    final correctAnswer = question.answer;

                    final isCorrect =
                        userAnswer == correctAnswer;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              question.question,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 16),

                            const Text(
                              'Your Answer:',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              userAnswer,
                              style: TextStyle(
                                color: isCorrect
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Correct Answer:',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              correctAnswer,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Icon(
                                  isCorrect
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: isCorrect
                                      ? Colors.greenAccent
                                      : Colors.redAccent,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  isCorrect
                                      ? 'Correct'
                                      : 'Incorrect',
                                  style: TextStyle(
                                    color: isCorrect
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}