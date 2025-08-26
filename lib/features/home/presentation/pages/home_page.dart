import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/home/presentation/components/my_drawer.dart';
import 'package:social_media_app/features/home/presentation/components/post_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';

import '../../../post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final postCubit = context.read<PostCubits>();

  @override
  void initState() {
    super.initState();
    // Start watching posts in real-time
    postCubit.watchPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => UploadPostPage())),
              icon: Icon(Icons.add))
        ],
      ),
      drawer: const MyDrawer(),
      body: BlocBuilder<PostCubits, PostStates>(
        builder: (context, state) {
          if (state is PostsLoading || state is PostUploading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PostLoaded) {
            final allPosts = state.posts;

            if (allPosts.isEmpty) {
              return Center(
                child: Text("No Posts Available"),
              );
            }

            return ListView.builder(
                itemCount: allPosts.length,
                itemBuilder: (context, index) {
                  final post = allPosts[index];

                  return PostTile(
                    post: post,
                    onDeletePost: () => deletePost(post.id),
                  );
                });
          } else if (state is PostsError) {
            return Center(
              child: Text(state.message),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
