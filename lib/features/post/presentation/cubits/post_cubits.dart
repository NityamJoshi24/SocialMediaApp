import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/post/domain/repo/post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/storage/domain/storage_repo.dart';

import '../../domain/entities/post.dart';

class PostCubits extends Cubit<PostStates> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;
  StreamSubscription<List<Post>>? _postsSub;

  PostCubits({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      emit(PostUploading());
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      } else if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);

      await postRepo.createPost(newPost);
      // No need to emit here; the watcher will push PostLoaded shortly
    } catch (e) {
      emit(PostsError("Failed to Create Post: $e"));
    }
  }

  Future<void> fetchAllPosts() async {
    try {
      emit(PostsLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostsError("Failed to Fetch Post: $e"));
    }
  }

  void watchPosts() {
    _postsSub?.cancel();
    emit(PostsLoading());
    _postsSub = postRepo.watchAllPosts().listen((posts) {
      emit(PostLoaded(posts));
    }, onError: (e) {
      emit(PostsError("Failed to Watch Posts: $e"));
    });
  }

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {
      emit(PostsError("Failed to Delete Post: $e"));
    }
  }

  @override
  Future<void> close() {
    _postsSub?.cancel();
    return super.close();
  }

  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostsError("Failed to toggle like: $e"));
    }
  }
}
