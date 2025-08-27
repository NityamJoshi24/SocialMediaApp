import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String text;
  final DateTime timestamp;

  Comment(
      {required this.id,
      required this.postId,
      required this.text,
      required this.timestamp,
      required this.userId,
      required this.userName});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
        id: json['id']?.toString() ?? '',
        postId: json['postId']?.toString() ?? '',
        text: json['text']?.toString() ?? '',
        timestamp: (json['timestamp'] is Timestamp)
            ? (json['timestamp'] as Timestamp).toDate()
            : (json['timestamp'] is DateTime)
                ? (json['timestamp'] as DateTime)
                : DateTime.now(),
        userId: json['userId']?.toString() ?? '',
        userName: json['userName']?.toString() ?? '');
  }
}
