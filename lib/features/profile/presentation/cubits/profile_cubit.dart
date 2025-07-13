import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/domain/repo/profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  Future<void> fetchUserProfile(String uid) async {
    try {
      emit(Profileloading());
      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError(message: "User Not Found"));
      }
    } catch (e) {
      emit(ProfileError(message: "User Not Found"));
    }
  }

  Future<void> updateProfile({required String uid, String? newBio}) async {
    emit(Profileloading());

    try {
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError(message: "Failed to fetch user for profile update"));
        return;
      }

      final updatedProfile =
          currentUser.copyWith(bio: newBio ?? currentUser.bio);

      await profileRepo.updateProfile(updatedProfile);

      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError(message: "$e"));
    }
  }
}
