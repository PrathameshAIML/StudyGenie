import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../widgets/glass_container.dart';
import '../theme/app_theme.dart';

class MCQScreen extends StatefulWidget {
  const MCQScreen({super.key});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  String _difficulty = 'easy';
  String _coLevel = 'CO1';

  List<int>? _selectedFileBytes;
  String? _selectedFileName;

  final _numQuestionsController = TextEditingController(text: '5');
  final _startPageController = TextEditingController(text: '1');
  final _endPageController = TextEditingController(text: '5');

  bool _isLoading = false;

  @override
  void dispose() {
    _numQuestionsController.dispose();
    _startPageController.dispose();
    _endPageController.dispose();
    super.dispose();
  }

  Future<void> _pickDocument() async {
    const XTypeGroup pdfType = XTypeGroup(
      label: 'PDF',
      extensions: ['pdf'],
    );

    final XFile? file = await openFile(
      acceptedTypeGroups: [pdfType],
    );

    if (file != null) {
      final bytes = await file.readAsBytes();

      setState(() {
        _selectedFileBytes = bytes.toList();
        _selectedFileName = file.name;
      });
    }
  }

  Future<void> _generateMCQ() async {
    if (_selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final response = await apiService.generateQuiz(
        fileBytes: _selectedFileBytes!,
        fileName: _selectedFileName ?? 'document.pdf',
        numQuestions: int.tryParse(_numQuestionsController.text) ?? 5,
        difficulty: _difficulty,
        coLevel: _coLevel,
        startPage: int.tryParse(_startPageController.text) ?? 1,
        endPage: int.tryParse(_endPageController.text) ?? 5,
        isMcq: true,
      );

      if (mounted) {
        context.push('/generated', extra: {
          'type': 'mcq',
          'response': response,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildDifficultyChip(String label, String value) {
    final isSelected = _difficulty == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _difficulty = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? AppTheme.accentColor : const Color(0xFF1C2738),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCOChip(String label, String value) {
    final isSelected = _coLevel == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _coLevel = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? AppTheme.accentColor : const Color(0xFF1C2738),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📝 MCQ Generator',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Generate AI powered multiple choice questions from educational PDFs',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📄 Upload PDF',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _pickDocument,
                          child: const Text('Choose PDF'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          _selectedFileName != null
                              ? _selectedFileName!
                              : 'No PDF selected',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Number of Questions',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _numQuestionsController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'e.g., 5',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Difficulty',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDifficultyChip('Easy', 'easy'),
                          _buildDifficultyChip('Medium', 'medium'),
                          _buildDifficultyChip('Hard', 'hard'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                GlassContainer(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Bloom's Taxonomy Level",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          _buildCOChip('CO1\nRemember', 'CO1'),
                          _buildCOChip('CO2\nUnderstand', 'CO2'),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          _buildCOChip('CO3\nApply', 'CO3'),
                          _buildCOChip('CO4\nAnalyze', 'CO4'),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Start Page',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _startPageController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: GlassContainer(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'End Page',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _endPageController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _generateMCQ,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Generate MCQs',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
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