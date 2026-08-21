// To parse this JSON data, do
//
//     final removeWishlistResponseModel = removeWishlistResponseModelFromJson(jsonString);

import 'dart:convert';

RemoveWishlistResponseModel removeWishlistResponseModelFromJson(String str) => RemoveWishlistResponseModel.fromJson(json.decode(str));

String removeWishlistResponseModelToJson(RemoveWishlistResponseModel data) => json.encode(data.toJson());

class RemoveWishlistResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  dynamic result;

  RemoveWishlistResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory RemoveWishlistResponseModel.fromJson(Map<String, dynamic> json) => RemoveWishlistResponseModel(
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

