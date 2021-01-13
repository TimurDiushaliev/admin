// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.company,
    this.username,
    this.password,
    this.firstName,
    this.lastName,
    this.position,
  });

  String company;
  String username;
  String password;
  String firstName;
  String lastName;
  String position;

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        company: json["company"],
        username: json["username"],
        password: json["password"],
        firstName: json["first_name"],
        lastName: json["last_name"],
        position: json["position"],
      );

  Map<String, dynamic> toJson() => {
        "company": company,
        "username": username,
        "password": password,
        "first_name": firstName,
        "last_name": lastName,
        "position": position,
      };
}
