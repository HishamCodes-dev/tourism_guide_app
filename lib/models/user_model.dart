class UserModel {
  final String uid;
  final String email;
  final String name;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
  });

  /// Factory constructor to create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(dynamic user, {String? displayName}) {
    return UserModel(
      uid: user.uid as String? ?? '',
      email: user.email as String? ?? '',
      name: displayName ?? user.displayName as String? ?? '',
    );
  }

  /// Converts UserModel to Map for Firebase/Database operations
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  /// Factory constructor to create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
    );
  }
}
