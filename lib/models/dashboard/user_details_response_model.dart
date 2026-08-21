// To parse this JSON data, do
//
//     final userDetailsResponseModel = userDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

UserDetailsResponseModel userDetailsResponseModelFromJson(String str) => UserDetailsResponseModel.fromJson(json.decode(str));

String userDetailsResponseModelToJson(UserDetailsResponseModel data) => json.encode(data.toJson());

class UserDetailsResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  Result result;

  UserDetailsResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory UserDetailsResponseModel.fromJson(Map<String, dynamic> json) => UserDetailsResponseModel(
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
    errorMessages: List<dynamic>.from(json["errorMessages"].map((x) => x)),
    result: Result.fromJson(json["result"]),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "errorMessages": List<dynamic>.from(errorMessages.map((x) => x)),
    "result": result.toJson(),
  };
}

class Result {
  String userName;
  String phoneNumber;

  Result({
    required this.userName,
    required this.phoneNumber,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    userName: json["userName"],
    phoneNumber: json["phoneNumber"],
  );

  Map<String, dynamic> toJson() => {
    "userName": userName,
    "phoneNumber": phoneNumber,
  };
}
