import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_model.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedOption;

  final List<String> _userAnswers = [];

  void _nextQuestion() {
    if (_selectedOption != null) {
      _userAnswers.add(_selectedOption!);

      if (_selectedOption == widget.questions[_currentIndex].answer) {
        _score++;
      }
    }

    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
      });
    } else {
      context.go(
        '/result',
        extra: {
          'score': _score,
          'total': widget.questions.length,
          'questions': widget.questions,
          'userAnswers': _userAnswers,
        },
      );
    }
  }

  Widget _buildOption(String option) {
    final isSelected = _selectedOption == option;

    return GestureDetector(
      onTap: () => setState(() => _selectedOption = option),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.accentColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected
                ? AppTheme.accentColor
                : Colors.white.withOpacity(0.1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppTheme.accentColor
                  : Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No questions available'),
        ),
      );
    }

    final question = widget.questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Question ${_currentIndex + 1}/${widget.questions.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppTheme.primaryGradientMiddle,
                title: const Text(
                  'Quit Quiz?',
                  style: TextStyle(color: Colors.white),
                ),
                content: const Text(
                  'Your progress will be lost.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go('/home');
                    },
                    child: const Text(
                      'Quit',
                      style: TextStyle(color: Colors.redAccent),
                    ),
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
                  value: (_currentIndex + 1) /
                      widget.questions.length,
                  backgroundColor:
                      Colors.white.withOpacity(0.1),
                  color: AppTheme.accentColor,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.question,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 22,
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: 40),
                        if (question.options != null)
                          ...question.options!
                              .map((option) =>
                                  _buildOption(option)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _selectedOption == null
                        ? null
                        : _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      disabledBackgroundColor:
                          Colors.white.withOpacity(0.1),
                    ),
                    child: Text(
                      _currentIndex ==
                              widget.questions.length - 1
                          ? 'Finish'
                          : 'Next',
                      style:
                          const TextStyle(fontSize: 18),
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