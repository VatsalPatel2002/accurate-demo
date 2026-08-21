// To parse this JSON data, do
//
//     final productDetailsResponseModel = productDetailsResponseModelFromJson(jsonString);

import 'dart:convert';

ProductDetailsResponseModel productDetailsResponseModelFromJson(String str) =>
    ProductDetailsResponseModel.fromJson(json.decode(str));

String productDetailsResponseModelToJson(ProductDetailsResponseModel data) =>
    json.encode(data.toJson());

class ProductDetailsResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  Result result;

  ProductDetailsResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory ProductDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      ProductDetailsResponseModel(
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
  int productId;
  String productName;
  String productImage;
  String description;
  dynamic attributeName;
  bool isCompany;
  bool isAttribute;
  String productCode;
  bool isAddToCart;
  List<Price> prices;
  List<Company> company;
  List<AttributeValue> attributeValues;

  Result({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.description,
    required this.attributeName,
    required this.isCompany,
    required this.isAttribute,
    required this.productCode,
    required this.isAddToCart,
    required this.prices,
    required this.company,
    required this.attributeValues,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        productId: json["productId"],
        productName: json["productName"],
        productImage: json["productImage"],
        description: json["description"],
        attributeName: json["attributeName"],
        isCompany: json["isCompany"],
        isAttribute: json["isAttribute"],
        productCode: json["productCode"],
        isAddToCart: json["isAddToCart"],
        prices: List<Price>.from(json["prices"].map((x) => Price.fromJson(x))),
        company: json["company"] == null
            ? []
            : List<Company>.from(
                json["company"]!.map((x) => Company.fromJson(x))),
        attributeValues: json["attributeValues"] == null
            ? []
            : List<AttributeValue>.from(json["attributeValues"]!
                .map((x) => AttributeValue.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "productId": productId,
        "productName": productName,
        "productImage": productImage,
        "description": description,
        "attributeName": attributeName,
        "isCompany": isCompany,
        "isAttribute": isAttribute,
        "productCode": productCode,
        "isAddToCart": isAddToCart,
        "prices": List<dynamic>.from(prices.map((x) => x.toJson())),
        "company": List<dynamic>.from(company.map((x) => x.toJson())),
        "attributeValues":
            List<dynamic>.from(attributeValues.map((x) => x.toJson())),
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

class AttributeValue {
  int id;
  String name;

  AttributeValue({
    required this.id,
    required this.name,
  });

  factory AttributeValue.fromJson(Map<String, dynamic> json) => AttributeValue(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class Price {
  int companyId;
  dynamic attributeId;
  int price;
  int discount;

  Price({
    required this.companyId,
    required this.attributeId,
    required this.price,
    required this.discount,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        companyId: json["companyId"],
        attributeId: json["attributeId"],
        price: json["price"],
        discount: json["discount"],
      );

  Map<String, dynamic> toJson() => {
        "companyId": companyId,
        "attributeId": attributeId,
        "price": price,
        "discount": discount,
      };
}
