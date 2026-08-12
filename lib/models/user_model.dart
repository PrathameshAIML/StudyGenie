class UserModel {
  final String uid;
  final String? email;
  final String? displayName;

  UserModel({
    required this.uid,
    this.email,
    this.displayName,
  });

  factory UserModel.fromFirebaseUser(dynamic user) {
    if (user == null) {
      throw Exception('User cannot be null');
    }
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
    );
  }
}
