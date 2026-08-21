// To parse this JSON data, do
//
//     final viewOrderResponseModel = viewOrderResponseModelFromJson(jsonString);

import 'dart:convert';

ViewOrderResponseModel viewOrderResponseModelFromJson(String str) => ViewOrderResponseModel.fromJson(json.decode(str));

String viewOrderResponseModelToJson(ViewOrderResponseModel data) => json.encode(data.toJson());

class ViewOrderResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  Result result;

  ViewOrderResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory ViewOrderResponseModel.fromJson(Map<String, dynamic> json) => ViewOrderResponseModel(
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
  String address;
  List<OrderItem> orderItems;

  Result({
    required this.address,
    required this.orderItems,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    address: json["address"],
    orderItems: List<OrderItem>.from(json["orderItems"].map((x) => OrderItem.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "address": address,
    "orderItems": List<dynamic>.from(orderItems.map((x) => x.toJson())),
  };
}

class OrderItem {
  int id;
  int quantity;
  int unitPrice;
  int discount;
  String productName;

  OrderItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.productName,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json["id"],
    quantity: json["quantity"],
    unitPrice: json["unitPrice"],
    discount: json["discount"],
    productName: json["productName"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "quantity": quantity,
    "unitPrice": unitPrice,
    "discount": discount,
    "productName": productName,
  };
}
