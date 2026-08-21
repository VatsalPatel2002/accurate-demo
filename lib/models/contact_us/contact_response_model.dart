// To parse this JSON data, do
//
//     final contactResponseModel = contactResponseModelFromJson(jsonString);

import 'dart:convert';

ContactResponseModel contactResponseModelFromJson(String str) => ContactResponseModel.fromJson(json.decode(str));

String contactResponseModelToJson(ContactResponseModel data) => json.encode(data.toJson());

class ContactResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  Result result;

  ContactResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory ContactResponseModel.fromJson(Map<String, dynamic> json) => ContactResponseModel(
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
  int currentPage;
  int totalPages;
  int pageSize;
  int totalCount;
  bool hasPrevious;
  bool hasNext;
  List<Datum> data;

  Result({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPrevious,
    required this.hasNext,
    required this.data,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    pageSize: json["pageSize"],
    totalCount: json["totalCount"],
    hasPrevious: json["hasPrevious"],
    hasNext: json["hasNext"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "pageSize": pageSize,
    "totalCount": totalCount,
    "hasPrevious": hasPrevious,
    "hasNext": hasNext,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  int id;
  String branchName;
  String phoneNumber;
  String email;
  String address;

  Datum({
    required this.id,
    required this.branchName,
    required this.phoneNumber,
    required this.email,
    required this.address,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    branchName: json["branchName"],
    phoneNumber: json["phoneNumber"],
    email: json["email"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "branchName": branchName,
    "phoneNumber": phoneNumber,
    "email": email,
    "address": address,
  };
}
