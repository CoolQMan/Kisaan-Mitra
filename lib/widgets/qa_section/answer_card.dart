import 'package:flutter/material.dart';
import 'package:kisaan_mitra/models/question_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class AnswerCard extends StatelessWidget {
  final AnswerModel answer;
  final VoidCallback onUpvote;
  final String currentUserId;

  const AnswerCard({
    Key? key,
    required this.answer,
    required this.onUpvote,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasUpvoted = answer.upvotedBy.contains(currentUserId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Answer Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: Text(
                    answer.userName.substring(0, 1),
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      answer.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      timeago.format(answer.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Answer Text
            Text(
              answer.answer,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Upvote Button
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: onUpvote,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Icon(
                          hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16,
                          color: hasUpvoted ? Colors.blue : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${answer.upvotes} ${answer.upvotes == 1 ? 'upvote' : 'upvotes'}',
                          style: TextStyle(
                            color: hasUpvoted ? Colors.blue : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
