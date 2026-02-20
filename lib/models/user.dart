class User {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String plan;
  final bool isAdmin;
  final String token;
  final String profilePicture;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.plan,
    required this.isAdmin,
    required this.token,
    required this.profilePicture,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['_id'],
    fullName: json['full_name'],
    email: json['email'],
    phoneNumber: json['phone_number'],
    plan: json['plan'],
    isAdmin: json['is_admin'],
    token: json['token'],
    profilePicture: (json['profile_picture'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "email": email,
    "phone_number": phoneNumber,
    "plan": plan,
    "is_admin": isAdmin,
    "token": token,
    "profile_picture": profilePicture,
  };
}
