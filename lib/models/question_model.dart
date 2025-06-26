class QuestionModel {
  final String id;
  final String userId;
  final String userName;
  final String question;
  final String? aiAnswer;
  final List<AnswerModel> communityAnswers;
  final DateTime createdAt;
  final int viewCount;

  QuestionModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.question,
    this.aiAnswer,
    required this.communityAnswers,
    required this.createdAt,
    required this.viewCount,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      question: json['question'],
      aiAnswer: json['aiAnswer'],
      communityAnswers: (json['communityAnswers'] as List)
          .map((answer) => AnswerModel.fromJson(answer))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      viewCount: json['viewCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'question': question,
      'aiAnswer': aiAnswer,
      'communityAnswers': communityAnswers.map((answer) => answer.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'viewCount': viewCount,
    };
  }
}

class AnswerModel {
  final String id;
  final String userId;
  final String userName;
  final String answer;
  final DateTime createdAt;
  final int upvotes;
  final List<String> upvotedBy;

  AnswerModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.answer,
    required this.createdAt,
    required this.upvotes,
    required this.upvotedBy,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      answer: json['answer'],
      createdAt: DateTime.parse(json['createdAt']),
      upvotes: json['upvotes'],
      upvotedBy: List<String>.from(json['upvotedBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'answer': answer,
      'createdAt': createdAt.toIso8601String(),
      'upvotes': upvotes,
      'upvotedBy': upvotedBy,
    };
  }
}
