import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/post/domain/repo/post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/storage/domain/storage_repo.dart';

import '../../domain/entities/post.dart';

class PostCubits extends Cubit<PostStates> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubits({required this.postRepo, required this.storageRepo})
      : super(PostsInitial());

  Future<void> createPost(Post post,
      {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      if (imagePath != null) {
        emit(PostUploading());
        imageUrl =
            await storageRepo.uploadProfileImageMobile(imagePath, post.id);
      } else if (imageBytes != null) {
        emit(PostUploading());
        imageUrl = await storageRepo.uploadProfileImageWeb(imageBytes, post.id);
      }

      final newPost = post.copyWith(imageUrl: imageUrl);

      postRepo.createPost(newPost);
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

  Future<void> deletePost(String postId) async {
    try {
      await postRepo.deletePost(postId);
    } catch (e) {}
  }
}
