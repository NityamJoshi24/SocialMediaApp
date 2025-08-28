import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/presentation/components/comment_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/pages/profile_page.dart';

import '../../domain/entities/post.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePost;
  const PostTile({super.key, required this.onDeletePost, required this.post});

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  late final profileCubit = context.read<ProfileCubit>();
  late final postCubit = context.read<PostCubits>();

  bool isOwnPost = false;

  AppUser? currentUser;

  ProfileUser? postUser;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;

    if (currentUser != null) {
      isOwnPost = (widget.post.userId == currentUser!.uid);
    } else {
      isOwnPost = false; // fallback
    }
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (!mounted) return;
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  void toggleLikePost() {
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    postCubit
        .toggleLikePost(widget.post.id, currentUser!.uid)
        .catchError((error) {
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid);
        } else {
          widget.post.likes.remove(currentUser!.uid);
        }
      });
    });
  }

  final commentTextController = TextEditingController();

  void openNewCommentBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text("Add a new comment"),
              content: MyTextField(
                  controller: commentTextController,
                  hintText: "Type a comment",
                  obscureText: false),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: () {
                      addComment();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Add")),
              ],
            ));
  }

  void addComment() {
    final newComment = Comment(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        postId: widget.post.id,
        text: commentTextController.text,
        timestamp: DateTime.now(),
        userId: currentUser!.uid,
        userName: currentUser!.name);

    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  void showOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              if (widget.onDeletePost != null) {
                widget.onDeletePost!();
              }
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(uid: widget.post.userId))),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  postUser != null && postUser!.profileImageURL.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: postUser!.profileImageURL,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.person),
                          imageBuilder: (context, imageProvider) => Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.cover)),
                          ),
                        )
                      : const Icon(Icons.person),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    postUser?.name ?? widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (isOwnPost)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => const SizedBox(
              height: 430,
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      GestureDetector(
                          onTap: toggleLikePost,
                          child: Icon(
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.post.likes.contains(currentUser!.uid)
                                ? Colors.red
                                : Theme.of(context).colorScheme.primary,
                          )),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                    onTap: openNewCommentBox,
                    child: Icon(
                      Icons.comment,
                      color: Theme.of(context).colorScheme.primary,
                    )),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12),
                ),
                const Spacer(),
                Text(widget.post.timestamp.toString())
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20),
            child: Row(
              children: [
                Text(
                  widget.post.userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.post.text,
                ),
              ],
            ),
          ),
          BlocBuilder<PostCubits, PostStates>(
            builder: (context, state) {
              if (state is PostLoaded) {
                final post = state.posts.firstWhere(
                  (post) => (post.id == widget.post.id),
                );

                if (post.comments.isNotEmpty) {
                  int showCommentCount = post.comments.length;

                  return ListView.builder(
                      itemCount: showCommentCount,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];

                        return CommentTile(comment: comment);
                      });
                }
              }

              if (state is PostsLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is PostsError) {
                return Center(
                  child: Text(state.message),
                );
              } else {
                return const Center(
                  child: SizedBox(),
                );
              }
            },
          )
        ],
      ),
    );
  }
}
