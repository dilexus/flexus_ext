class AuthUser {
  String? id;
  String? name;
  String? email;
  bool? emailVerified;
  String? provider;
  String? photoURL;

  AuthUser(
      {this.id,
      this.name,
      this.email,
      this.emailVerified,
      this.provider,
      this.photoURL});

  AuthUser.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    provider = json['provider'];
    photoURL = json['photoURL'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['emailVerified'] = emailVerified;
    data['provider'] = provider;
    data['photoURL'] = photoURL;
    return data;
  }
}
