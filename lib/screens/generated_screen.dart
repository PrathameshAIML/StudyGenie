import '../utils/pdf_download.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/quiz_model.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class GeneratedScreen extends StatelessWidget {
  final Map<String, dynamic> data;

  const GeneratedScreen({super.key, required this.data});

  Future<void> _downloadPdf(
  BuildContext context,
  QuizResponse response,
) async {
  try {
    await downloadPdf(
      response.pdfBase64,
      response.filename.isNotEmpty
          ? response.filename
          : 'QuizWhiz_Questions.pdf',
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF downloaded successfully!'),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to download PDF: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final String type = data['type'] as String;
    final QuizResponse response = data['response'] as QuizResponse;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassContainer(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.accentColor, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Successfully Generated!',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your ${response.questions.length} questions are ready.',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (type == 'mcq') {
                            context.push('/quiz', extra: response.questions);
                          } else {
                            context.push('/fill-quiz', extra: response.questions);
                          }
                        },
                        child: const Text('Start Quiz Now'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () => _downloadPdf(context, response),
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download PDF'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentColor),
                          foregroundColor: AppTheme.accentColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

