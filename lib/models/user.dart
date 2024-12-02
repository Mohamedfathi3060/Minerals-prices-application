class UserModel {
  final String? username;
  final String? email;
  final String? password;

  const UserModel({this.username, this.email, this.password});
  tojson() {
    return {"username": username, "email": email, "password": password};
  }
  factory UserModel.fromJson(Map<String, dynamic> user) {
    return UserModel(
      username: user['username'] ?? '',  
      email: user['Email'] ?? '',       
      password: user['password'] ?? '',  
    );
  }
}
