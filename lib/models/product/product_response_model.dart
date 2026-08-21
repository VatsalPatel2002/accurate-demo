// To parse this JSON data, do
//
//     final productResponseModel = productResponseModelFromJson(jsonString);

import 'dart:convert';

ProductResponseModel productResponseModelFromJson(String str) => ProductResponseModel.fromJson(json.decode(str));

String productResponseModelToJson(ProductResponseModel data) => json.encode(data.toJson());

class ProductResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  Result result;

  ProductResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) => ProductResponseModel(
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
  List<Company> company;
  Products products;

  Result({
    required this.company,
    required this.products,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
    company: List<Company>.from(json["company"].map((x) => Company.fromJson(x))),
    products: Products.fromJson(json["products"]),
  );

  Map<String, dynamic> toJson() => {
    "company": List<dynamic>.from(company.map((x) => x.toJson())),
    "products": products.toJson(),
  };
}

class Company {
  int id;
  String name;

  Company({
    required this.id,
    required this.name,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Products {
  int currentPage;
  int totalPages;
  int pageSize;
  int totalCount;
  bool hasPrevious;
  bool hasNext;
  List<Datum> data;

  Products({
    required this.currentPage,
    required this.totalPages,
    required this.pageSize,
    required this.totalCount,
    required this.hasPrevious,
    required this.hasNext,
    required this.data,
  });

  factory Products.fromJson(Map<String, dynamic> json) => Products(
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
  int productId;
  String productName;
  String productImage;
  String productCode;
  bool isInWishList;

  Datum({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productCode,
    required this.isInWishList,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    productId: json["productId"],
    productName: json["productName"],
    productImage: json["productImage"],
    productCode: json["productCode"],
    isInWishList: json["isInWishList"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "productName": productName,
    "productImage": productImage,
    "productCode": productCode,
    "isInWishList": isInWishList,
  };
}
