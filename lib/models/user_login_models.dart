class UserLoginModels {
  final String uid;
  final String email;
  final String name;

  UserLoginModels({
    required this.uid,
    required this.email,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'name': name,
      };

  factory UserLoginModels.fromJson(Map<String, dynamic> json) => UserLoginModels(
        uid: json['uid'],
        email: json['email'],
        name: json['name'],
      );
}
