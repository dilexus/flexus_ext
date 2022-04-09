import '../../enums/login_type.dart';

class AuthUser {
  String? id;
  String? name;
  String? email;
  bool? emailVerified;
  String? provider;
  String? photoURL;
  LoginType? loginType;

  AuthUser(
      {this.id,
      this.name,
      this.email,
      this.emailVerified,
      this.provider,
      this.photoURL,
      this.loginType});
}
