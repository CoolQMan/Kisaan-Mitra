import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/question_model.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:kisaan_mitra/widgets/qa_section/answer_card.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:uuid/uuid.dart';

class QuestionDetailScreen extends StatefulWidget {
  final QuestionModel question;

  const QuestionDetailScreen({
    Key? key,
    required this.question,
  }) : super(key: key);

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  final TextEditingController _answerController = TextEditingController();
  final AuthService _authService = AuthService();
  late QuestionModel _question;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _question = widget.question;
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _upvoteAnswer(String answerId) {
    setState(() {
      final userId = _authService.currentUser?.id ?? 'unknown';

      _question = QuestionModel(
        id: _question.id,
        userId: _question.userId,
        userName: _question.userName,
        question: _question.question,
        aiAnswer: _question.aiAnswer,
        communityAnswers: _question.communityAnswers.map((answer) {
          if (answer.id == answerId) {
            final hasUpvoted = answer.upvotedBy.contains(userId);

            return AnswerModel(
              id: answer.id,
              userId: answer.userId,
              userName: answer.userName,
              answer: answer.answer,
              createdAt: answer.createdAt,
              upvotes: hasUpvoted ? answer.upvotes - 1 : answer.upvotes + 1,
              upvotedBy: hasUpvoted
                  ? answer.upvotedBy.where((id) => id != userId).toList()
                  : [...answer.upvotedBy, userId],
            );
          }
          return answer;
        }).toList(),
        createdAt: _question.createdAt,
        viewCount: _question.viewCount,
      );
    });
  }

  Future<void> _submitAnswer() async {
    final answer = _answerController.text.trim();

    if (answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your answer')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // In a real app, this would send the answer to a backend service
      await Future.delayed(const Duration(seconds: 1));

      // Create a new answer
      final newAnswer = AnswerModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser?.id ?? 'unknown',
        userName: _authService.currentUser?.name ?? 'Anonymous',
        answer: answer,
        createdAt: DateTime.now(),
        upvotes: 0,
        upvotedBy: [],
      );

      // Update the question with the new answer
      setState(() {
        _question = QuestionModel(
          id: _question.id,
          userId: _question.userId,
          userName: _question.userName,
          question: _question.question,
          aiAnswer: _question.aiAnswer,
          communityAnswers: [..._question.communityAnswers, newAnswer],
          createdAt: _question.createdAt,
          viewCount: _question.viewCount,
        );
        _isSubmitting = false;
        _answerController.clear();
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting answer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Detail'),
      ),
      body: Column(
        children: [
          // Question Section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Header
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        child: Text(
                          _question.userName.substring(0, 1),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _question.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            timeago.format(_question.createdAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Question Text
                  Text(
                    _question.question,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AI Answer
                  if (_question.aiAnswer != null) ...[
                    const Text(
                      'AI Answer',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.smart_toy,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Kisaan Mitra AI',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_question.aiAnswer!),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Community Answers
                  Text(
                    'Community Answers (${_question.communityAnswers.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_question.communityAnswers.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Center(
                        child: Text(
                          'Be the first to answer this question!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _question.communityAnswers.length,
                      itemBuilder: (context, index) {
                        final answer = _question.communityAnswers[index];
                        return AnswerCard(
                          answer: answer,
                          onUpvote: () => _upvoteAnswer(answer.id),
                          currentUserId: _authService.currentUser?.id ?? 'unknown',
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

          // Answer Input Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: 'Write your answer...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                    minLines: 1,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitAnswer,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
