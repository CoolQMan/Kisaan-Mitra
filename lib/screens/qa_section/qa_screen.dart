import 'package:flutter/material.dart';
import 'package:kisaan_mitra/config/routes.dart';
import 'package:kisaan_mitra/models/question_model.dart';
import 'package:kisaan_mitra/services/ai_service.dart';
import 'package:kisaan_mitra/services/auth_service.dart';
import 'package:kisaan_mitra/widgets/qa_section/question_card.dart';

import '../../services/storage_service.dart';

class QAScreen extends StatefulWidget {
  const QAScreen({Key? key}) : super(key: key);

  @override
  State<QAScreen> createState() => _QAScreenState();
}

class _QAScreenState extends State<QAScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final AIService _aiService = AIService();
  final AuthService _authService = AuthService();

  late TabController _tabController;
  List<QuestionModel> _questions = [];
  List<QuestionModel> _filteredQuestions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _filterQuestions(_searchController.text);
    }
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get questions from storage
      final storageService = StorageService();

      // If storage is empty, add some initial mock questions
      if (storageService.getAllQuestions().isEmpty) {
        final currentUserId = _authService.currentUser?.id ?? 'unknown';

        // Add mock questions
        storageService.addQuestion(QuestionModel(
          id: '3',
          userId: 'user5',
          userName: 'Anita Patel',
          question: 'What is the ideal soil pH for growing tomatoes?',
          aiAnswer:
              'Tomatoes prefer slightly acidic soil with a pH between 6.0 and 6.8.',
          communityAnswers: [],
          createdAt: DateTime.now().subtract(const Duration(hours: 12)),
          viewCount: 15,
        ));

        storageService.addQuestion(QuestionModel(
          id: '2',
          userId: currentUserId,
          userName: _authService.currentUser?.name ?? 'You',
          question: 'How to control aphids in mustard crop?',
          aiAnswer:
              'To control aphids in mustard, you can use neem oil spray or insecticidal soap.',
          communityAnswers: [],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          viewCount: 28,
        ));

        storageService.addQuestion(QuestionModel(
          id: '1',
          userId: 'user1',
          userName: 'Farmer Singh',
          question: 'What is the best time to sow wheat in Punjab?',
          aiAnswer:
              'The best time to sow wheat in Punjab is from late October to mid-November.',
          communityAnswers: [],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          viewCount: 42,
        ));
      }

      // Get all questions from storage
      final allQuestions = storageService.getAllQuestions();

      setState(() {
        _questions = allQuestions;
        _filterQuestions('');
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _filterQuestions(String query) {
    setState(() {
      // First filter by search query
      var filtered = query.isEmpty
          ? _questions
          : _questions
              .where(
                  (q) => q.question.toLowerCase().contains(query.toLowerCase()))
              .toList();

      // Then filter by tab selection (All or My Questions)
      if (_tabController.index == 1) {
        // "My Questions" tab - only show user's questions
        final currentUserId = _authService.currentUser?.id ?? '';
        filtered = filtered.where((q) => q.userId == currentUserId).toList();
      }

      _filteredQuestions = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Q&A Section'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Questions'),
            Tab(text: 'My Questions'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search questions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: _filterQuestions,
                  ),
                ),

                // Question List
                Expanded(
                  child: _filteredQuestions.isEmpty
                      ? Center(
                          child: Text(
                            _tabController.index == 0
                                ? 'No questions found'
                                : 'You haven\'t asked any questions yet',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredQuestions.length,
                          itemBuilder: (context, index) {
                            final question = _filteredQuestions[index];
                            final isUserQuestion =
                                question.userId == _authService.currentUser?.id;

                            return QuestionCard(
                              question: question,
                              isUserQuestion: isUserQuestion,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.questionDetail,
                                  arguments: question,
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.askQuestion).then((_) {
            // Refresh questions when returning from ask question screen
            _loadQuestions();
          });
        },
        child: const Icon(Icons.add_comment),
      ),
    );
  }
}
