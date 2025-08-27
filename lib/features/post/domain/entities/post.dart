import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;

  Post({
    required this.id,
    required this.imageUrl,
    required this.text,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.likes,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
        id: id,
        imageUrl: imageUrl ?? this.imageUrl,
        text: text,
        timestamp: timestamp,
        userId: userId,
        userName: userName,
        likes: likes);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'likes': likes,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      timestamp: (json['timestamp'] is Timestamp)
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(), // fallback
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      likes: List<String>.from(json['likes'] ?? []),
    );
  }
}
