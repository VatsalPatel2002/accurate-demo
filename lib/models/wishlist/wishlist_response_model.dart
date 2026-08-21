// To parse this JSON data, do
//
//     final wishlistResponseModel = wishlistResponseModelFromJson(jsonString);

import 'dart:convert';

WishlistResponseModel wishlistResponseModelFromJson(String str) => WishlistResponseModel.fromJson(json.decode(str));

String wishlistResponseModelToJson(WishlistResponseModel data) => json.encode(data.toJson());

class WishlistResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  List<Result> result;

  WishlistResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory WishlistResponseModel.fromJson(Map<String, dynamic> json) => WishlistResponseModel(
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
  int productId;
  String productName;
  String productDescription;
  String productImage;
  String productCode;
  bool isAddedIntoCart;

  Result({
    required this.productId,
    required this.productName,
    required this.productDescription,
    required this.productImage,
    required this.productCode,
    required this.isAddedIntoCart,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    productId: json["productId"],
    productName: json["productName"],
    productDescription: json["productDescription"],
    productImage: json["productImage"],
    productCode: json["productCode"],
    isAddedIntoCart: json["isAddedIntoCart"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "productName": productName,
    "productDescription": productDescription,
    "productImage": productImage,
    "productCode": productCode,
    "isAddedIntoCart": isAddedIntoCart,
  };
}
