import '../entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Stream<List<Post>> watchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String postId);
  Future<List<Post>> fetchPostsByUserId(String userId);
}
