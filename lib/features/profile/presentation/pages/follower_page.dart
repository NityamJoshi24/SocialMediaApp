// ignore_for_file: prefer_const_literals_to_create_immutables, unnecessary_import

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/presentation/components/user_tile.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/responsive/constrained_scaffold.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage(
      {super.key, required this.followers, required this.following});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: ConstrainedScaffold(
          appBar: AppBar(
            bottom: TabBar(
              dividerColor: Colors.transparent,
              labelColor: Theme.of(context).colorScheme.inversePrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              tabs: [
                const Tab(
                  text: "Followers",
                ),
                const Tab(
                  text: "Following",
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _buildUserList(followers, "No Followers", context),
              _buildUserList(following, "No Followings", context),
            ],
          ),
        ));
  }

  Widget _buildUserList(
      List<String> uids, String emptyMessage, BuildContext context) {
    return uids.isEmpty
        ? Center(
            child: Text(emptyMessage),
          )
        : ListView.builder(
            itemCount: uids.length,
            itemBuilder: (context, index) {
              final uid = uids[index];

              return FutureBuilder(
                  future: context.read<ProfileCubit>().getUserProfile(uid),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return UserTile(user: user);
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const ListTile(
                        title: Text("Loading..."),
                      );
                    } else {
                      return const ListTile(
                        title: Text("User not found.."),
                      );
                    }
                  });
            });
  }
}
