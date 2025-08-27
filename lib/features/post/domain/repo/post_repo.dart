import 'package:social_media_app/features/post/domain/entities/comment.dart';

import '../entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Stream<List<Post>> watchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
  Future<void> toggleLikePost(String postId, String userId);
  Future<void> addComment(String postId, Comment comment);
  Future<void> deleteComment(String postId, String commentId);
}
