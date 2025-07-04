import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/models/question_model.dart';
import 'package:kisaan_mitra/services/ai_service.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:uuid/uuid.dart';

import '../../services/storage_service.dart';

class AskQuestionScreen extends StatefulWidget {
  const AskQuestionScreen({Key? key}) : super(key: key);

  @override
  State<AskQuestionScreen> createState() => _AskQuestionScreenState();
}

class _AskQuestionScreenState extends State<AskQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final AIService _aiService = AIService();
  final AuthService _authService = AuthService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your question')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // In a real app, this would send the question to a backend service
      // and get an AI-generated answer
      await Future.delayed(const Duration(seconds: 2));

      // Create a new question with mock data
      final newQuestion = QuestionModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser?.id ?? 'unknown',
        userName: _authService.currentUser?.name ?? 'Anonymous',
        question: question,
        aiAnswer:
            'This is an AI-generated answer to your question about farming. In a real app, this would be generated by Gemini AI based on your specific question.',
        communityAnswers: [],
        createdAt: DateTime.now(),
        viewCount: 1,
      );
      StorageService().addQuestion(newQuestion);

      setState(() {
        _isSubmitting = false;
      });

      // Navigate to the question detail screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.questionDetail,
          arguments: newQuestion,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting question: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask a Question'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask the farming community',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Get answers from AI and experienced farmers',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Question Input
            TextField(
              controller: _questionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Type your farming question here...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Tips
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tips for good questions:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Be specific about your crop and location'),
                    Text(
                        '• Include relevant details like soil type and weather'),
                    Text('• Mention what you\'ve already tried'),
                    Text('• Add photos if possible (coming soon)'),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitQuestion,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Submitting...'),
                        ],
                      )
                    : const Text('Submit Question'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
