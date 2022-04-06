import 'package:intl/intl.dart';

class BillsProductResponse {
  List<BillsProduct> products;
  String status;
  String responseCode;
  String responseMessage;

  BillsProductResponse(
      {this.products, this.status, this.responseCode, this.responseMessage});

  BillsProductResponse.fromJson(Map<String, dynamic> json) {
    if (json['products'] != null) {
      products = new List<BillsProduct>();
      json['products'].forEach((v) {
        products.add(new BillsProduct.fromJson(v));
      });
    }
    status = json['status'];
    responseCode = json['response_code'];
    responseMessage = json['response_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.products != null) {
      data['products'] = this.products.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['response_code'] = this.responseCode;
    data['response_message'] = this.responseMessage;
    return data;
  }
}

class BillsProduct {
  String name;
  String description;
  String serviceCode;
  String providerName;
  int providerId;
  bool isPriceFixed;
  double amount;

  BillsProduct(
      {this.name,
        this.description,
        this.serviceCode,
        this.providerName,
        this.providerId,
        this.isPriceFixed,
        this.amount});

  String getFormattedAmount() {
    var formatter = NumberFormat('###,###,###,##0.00');
    return formatter.format(this.amount);
  }

  String getGroupName() {
    return "DSTV";
  }

  BillsProduct.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    description = json['description'];
    serviceCode = json['service_code'];
    providerName = json['provider_name'];
    providerId = json['provider_id'];
    isPriceFixed = json['is_price_fixed'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['description'] = this.description;
    data['service_code'] = this.serviceCode;
    data['provider_name'] = this.providerName;
    data['provider_id'] = this.providerId;
    data['is_price_fixed'] = this.isPriceFixed;
    data['amount'] = this.amount;
    return data;
  }
}
