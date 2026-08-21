// To parse this JSON data, do
//
//     final loginResponseModel = loginResponseModelFromJson(jsonString);

import 'dart:convert';

LoginResponseModel loginResponseModelFromJson(String str) => LoginResponseModel.fromJson(json.decode(str));

String loginResponseModelToJson(LoginResponseModel data) => json.encode(data.toJson());

class LoginResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  String result;

  LoginResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => LoginResponseModel(
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
    errorMessages: List<dynamic>.from(json["errorMessages"].map((x) => x)),
    result: json["result"],
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "errorMessages": List<dynamic>.from(errorMessages.map((x) => x)),
    "result": result,
  };
}
