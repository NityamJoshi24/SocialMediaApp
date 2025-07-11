class AppUser {
  final String uid;
  final String email;
  final String name;

  AppUser({required this.email, required this.name, required this.uid});

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> jsonUser) {
    return AppUser(
        email: jsonUser['email'], name: jsonUser['name'], uid: jsonUser['uid']);
  }
}
