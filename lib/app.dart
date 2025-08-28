import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_app/features/post/data/firebase_post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubits.dart';
import 'package:social_media_app/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/search/data/firebase_search_repo.dart';
import 'package:social_media_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_media_app/features/storage/data/firebase_storage_repo.dart';
import 'package:social_media_app/themes/theme_cubit.dart';

import 'features/auth/presentation/pages/auth_page.dart';
import 'features/home/presentation/pages/home_page.dart';

class MyApp extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final AuthRepo = FirebaseAuthRepo();
  final firebaseProfileRepo = FirebaseProfileRepo();
  final firebaseStorageRepo = FirebaseStorageRepo();
  final firebasePostRepo = FirebasePostRepo();
  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (context) => AuthCubit(authRepo: AuthRepo)..checkAuth(),
          ),
          BlocProvider<ProfileCubit>(
              create: (context) => ProfileCubit(
                  profileRepo: firebaseProfileRepo,
                  storageRepo: firebaseStorageRepo)),
          BlocProvider<PostCubits>(
              create: (context) => PostCubits(
                  postRepo: firebasePostRepo,
                  storageRepo: firebaseStorageRepo)),
          BlocProvider<SearchCubit>(
              create: (context) => SearchCubit(searchRepo: firebaseSearchRepo)),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
          )
        ],
        child: BlocBuilder<ThemeCubit, ThemeData>(
          builder: (context, currentTheme) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            home: BlocConsumer<AuthCubit, AuthStates>(
              builder: (context, authState) {
                // ignore: avoid_print
                print(authState);

                if (authState is Unauthenticated) {
                  return const AuthPage();
                }

                if (authState is Authenticated) {
                  return const HomePage();
                } else {
                  return const Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
            ),
          ),
        ));
  }
}
