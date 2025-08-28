// ignore_for_file: prefer_interpolation_to_compose_strings, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/domain/entities/post.dart';
import 'package:social_media_app/features/post/domain/repo/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final CollectionReference postsCollection =
      FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("Error catching post: $e");
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    await postsCollection.doc(postId).delete();
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      final List<Post> allPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return await _filterPostsByExistingUsers(allPosts);
    } catch (e) {
      throw Exception("Error fetching post: $e");
    }
  }

  @override
  Stream<List<Post>> watchAllPosts() {
    return postsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final posts = snapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return _filterPostsByExistingUsers(posts);
    });
  }

  Future<List<Post>> _filterPostsByExistingUsers(List<Post> posts) async {
    if (posts.isEmpty) return posts;

    final uniqueUserIds = posts.map((p) => p.userId).toSet().toList();

    // DEBUG: Log userIds encountered
    // ignore: avoid_print, prefer_interpolation_to_compose_strings
    print('[Posts] filtering by userIds: ' + uniqueUserIds.join(','));

    // Firestore whereIn limit is 10, so we batch queries
    final List<String> userIds = uniqueUserIds;
    final List<String> existingUserIds = [];

    for (int i = 0; i < userIds.length; i += 10) {
      final chunk =
          userIds.sublist(i, i + 10 > userIds.length ? userIds.length : i + 10);
      final querySnap = await firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      existingUserIds.addAll(querySnap.docs.map((d) => d.id));
    }

    final Set<String> existingSet = existingUserIds.toSet();
    // DEBUG: Log which userIds exist
    // ignore: avoid_print
    print('[Posts] existing userIds: ' + existingSet.join(','));
    return posts.where((p) => existingSet.contains(p.userId)).toList();
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String userId) async {
    try {
      final postsSnapshot =
          await postsCollection.where('userId', isEqualTo: userId).get();

      final userPosts = postsSnapshot.docs
          .map((doc) => Post.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      return userPosts;
    } catch (e) {
      throw Exception("Error fetching post: $e");
    }
  }

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        final hasLiked = post.likes.contains(userId);

        if (hasLiked) {
          post.likes.remove(userId);
        } else {
          post.likes.add(userId);
        }

        await postsCollection.doc(postId).update({
          'likes': post.likes,
        });
      } else {
        throw Exception("Post not Found");
      }
    } catch (e) {
      throw Exception("Error toggling like: $e");
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.add(comment);

        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not Found");
      }
    } catch (e) {
      throw Exception("Error Adding Comment: $e");
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        post.comments.removeWhere((comment) => comment.id == commentId);

        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList()
        });
      } else {
        throw Exception("Post not Found");
      }
    } catch (e) {
      throw Exception("Error Adding Comment: $e");
    }
  }
}
