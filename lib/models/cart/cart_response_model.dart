// To parse this JSON data, do
//
//     final cartResponseModel = cartResponseModelFromJson(jsonString);

import 'dart:convert';

CartResponseModel cartResponseModelFromJson(String str) =>
    CartResponseModel.fromJson(json.decode(str));

String cartResponseModelToJson(CartResponseModel data) =>
    json.encode(data.toJson());

class CartResponseModel {
  int statusCode;
  bool isSuccess;
  List<dynamic> errorMessages;
  List<ProductResult> result;

  CartResponseModel({
    required this.statusCode,
    required this.isSuccess,
    required this.errorMessages,
    required this.result,
  });

  factory CartResponseModel.fromJson(Map<String, dynamic> json) =>
      CartResponseModel(
        statusCode: json["statusCode"],
        isSuccess: json["isSuccess"],
        errorMessages: List<dynamic>.from(json["errorMessages"].map((x) => x)),
        result: List<ProductResult>.from(
            json["result"].map((x) => ProductResult.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "isSuccess": isSuccess,
        "errorMessages": List<dynamic>.from(errorMessages.map((x) => x)),
        "result": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}

class ProductResult {
  int cartId;
  int productId;
  String productName;
  String productImage;
  String productCode;
  String? attributeName;
  bool isCompany;
  bool isAttribute;
  int? attributeId;
  List<Price> prices;
  List<Company> company;
  List<AttributeValue> attributeValues;

  ProductResult({
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.productCode,
    required this.attributeName,
    required this.isCompany,
    required this.isAttribute,
    required this.attributeId,
    required this.prices,
    required this.company,
    required this.attributeValues,
  });

  factory ProductResult.fromJson(Map<String, dynamic> json) => ProductResult(
        cartId: json["cartId"],
        productId: json["productId"],
        productName: json["productName"],
        productImage: json["productImage"],
        productCode: json["productCode"],
        attributeName: json["attributeName"],
        isCompany: json["isCompany"],
        isAttribute: json["isAttribute"],
        attributeId: json["attributeId"],
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
        "cartId": cartId,
        "productId": productId,
        "productName": productName,
        "productImage": productImage,
        "productCode": productCode,
        "attributeName": attributeName,
        "isCompany": isCompany,
        "isAttribute": isAttribute,
        "attributeId": attributeId,
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
  int? attributeId;
  int price;
  int discount;

  Price({
    required this.companyId,
    required this.attributeId,
    required this.price,
    required this.discount,
  });

  factory Price.fromJson(Map<String, dynamic> json) => Price(
        companyId: json["companyId"] ?? 0,
        attributeId: json["attributeId"] ?? 0,
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
