import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_model.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class FillQuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const FillQuizScreen({super.key, required this.questions});

  @override
  State<FillQuizScreen> createState() => _FillQuizScreenState();
}

class _FillQuizScreenState extends State<FillQuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _nextQuestion() {
    final userAnswer = _answerController.text.trim().toLowerCase();
    final correctAnswer = widget.questions[_currentIndex].answer.toLowerCase();

    if (userAnswer == correctAnswer) {
      _score++;
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answerController.clear();
      });
    } else {
      context.go('/result', extra: {
        'score': _score,
        'total': widget.questions.length,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(body: Center(child: Text('No questions available')));
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Question ${_currentIndex + 1}/${widget.questions.length}', style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.primaryGradientMiddle,
                title: const Text('Quit Quiz?', style: TextStyle(color: Colors.white)),
                content: const Text('Your progress will be lost.', style: TextStyle(color: Colors.white70)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/home');
                    },
                    child: const Text('Quit', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentIndex + 1) / widget.questions.length,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  color: AppTheme.accentColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, height: 1.4),
                        ),
                        const SizedBox(height: 40),
                        TextField(
                          controller: _answerController,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          decoration: const InputDecoration(
                            labelText: 'Your Answer',
                            hintText: 'Type exactly the missing word',
                          ),
                          onChanged: (val) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _answerController.text.trim().isEmpty ? null : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: Colors.white.withOpacity(0.1),
                    ),
                    child: Text(
                      _currentIndex == widget.questions.length - 1 ? 'Finish' : 'Next',
                      style: const TextStyle(fontSize: 18),
                    ),
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
