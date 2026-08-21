// To parse this JSON data, do
//
//     final deleteCartResponseModel = deleteCartResponseModelFromJson(jsonString);

import 'dart:convert';

DeleteCartResponseModel deleteCartResponseModelFromJson(String str) => DeleteCartResponseModel.fromJson(json.decode(str));

String deleteCartResponseModelToJson(DeleteCartResponseModel data) => json.encode(data.toJson());

class DeleteCartResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  dynamic result;

  DeleteCartResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory DeleteCartResponseModel.fromJson(Map<String, dynamic> json) => DeleteCartResponseModel(
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
