// To parse this JSON data, do
//
//     final placeOrderCartResponseModel = placeOrderCartResponseModelFromJson(jsonString);

import 'dart:convert';

PlaceOrderCartResponseModel placeOrderCartResponseModelFromJson(String str) => PlaceOrderCartResponseModel.fromJson(json.decode(str));

String placeOrderCartResponseModelToJson(PlaceOrderCartResponseModel data) => json.encode(data.toJson());

class PlaceOrderCartResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  dynamic result;

  PlaceOrderCartResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory PlaceOrderCartResponseModel.fromJson(Map<String, dynamic> json) => PlaceOrderCartResponseModel(
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
