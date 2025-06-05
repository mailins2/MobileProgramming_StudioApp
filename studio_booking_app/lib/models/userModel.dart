class UserModel {
  final int id;
  final String? name;
  final String phone;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['userId'],
      name: data['userFullName'],
      phone: data['userPhoneNumber'],
    );
  }
}
