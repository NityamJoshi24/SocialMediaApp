import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/home/presentation/components/my_drawer_tile.dart';

import '../../../profile/presentation/pages/profile_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Divider(),
              MyDrawerTile(
                  icon: Icons.home,
                  onTap: () => Navigator.of(context).pop(),
                  title: "H O M E"),
              MyDrawerTile(
                  icon: Icons.person,
                  onTap: () {
                    Navigator.of(context).pop();
                    final user = context.read<AuthCubit>().currentUser;
                    String? uid = user!.uid;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(
                                  uid: uid,
                                )));
                  },
                  title: "P R O F I L E"),
              MyDrawerTile(
                  icon: Icons.search, onTap: () {}, title: "S E A R C H"),
              MyDrawerTile(
                  icon: Icons.settings, onTap: () {}, title: "S E T T I N G S"),
              Spacer(),
              MyDrawerTile(
                  icon: Icons.logout_outlined,
                  onTap: () {},
                  title: "L O G O U T"),
              SizedBox(
                height: 30,
              )
            ],
          ),
        ),
      ),
    );
  }
}
