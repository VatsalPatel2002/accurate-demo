// To parse this JSON data, do
//
//     final addressByUserIdResponseModel = addressByUserIdResponseModelFromJson(jsonString);

import 'dart:convert';

AddressByUserIdResponseModel addressByUserIdResponseModelFromJson(String str) => AddressByUserIdResponseModel.fromJson(json.decode(str));

String addressByUserIdResponseModelToJson(AddressByUserIdResponseModel data) => json.encode(data.toJson());

class AddressByUserIdResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  List<Result> result;

  AddressByUserIdResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory AddressByUserIdResponseModel.fromJson(Map<String, dynamic> json) => AddressByUserIdResponseModel(
    statusCode: json["statusCode"],
    isSuccess: json["isSuccess"],
    errorMessages: List<dynamic>.from(json["errorMessages"].map((x) => x)),
    result: List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "statusCode": statusCode,
    "isSuccess": isSuccess,
    "errorMessages": List<dynamic>.from(errorMessages.map((x) => x)),
    "result": List<dynamic>.from(result.map((x) => x.toJson())),
  };
}

class Result {
  int id;
  String name;

  Result({
    required this.id,
    required this.name,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
