// To parse this JSON data, do
//
//     final ordersResponseModel = ordersResponseModelFromJson(jsonString);

import 'dart:convert';

OrdersResponseModel ordersResponseModelFromJson(String str) => OrdersResponseModel.fromJson(json.decode(str));

String ordersResponseModelToJson(OrdersResponseModel data) => json.encode(data.toJson());

class OrdersResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  List<Result> result;

  OrdersResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory OrdersResponseModel.fromJson(Map<String, dynamic> json) => OrdersResponseModel(
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
  DateTime orderTime;
  int totalAmount;

  Result({
    required this.id,
    required this.orderTime,
    required this.totalAmount,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    id: json["id"],
    orderTime: DateTime.parse(json["orderTime"]),
    totalAmount: json["totalAmount"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderTime": orderTime.toIso8601String(),
    "totalAmount": totalAmount,
  };
}
