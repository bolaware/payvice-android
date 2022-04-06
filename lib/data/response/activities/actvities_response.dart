import 'package:intl/intl.dart';

class ActivitiesResponse {
  List<Activity> data;
  String status;
  String statusCode;
  String message;

  ActivitiesResponse({this.data, this.status, this.statusCode, this.message});

  ActivitiesResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<Activity>();
      json['data'].forEach((v) {
        data.add(new Activity.fromJson(v));
      });
    }
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Activity {
  int id;
  String remarks;
  String status;
  String currency;
  String product;
  int productId;
  int featureId;
  String dateCreated;
  double transactionAmount;
  String direction;

  Activity(
      {this.id,
        this.remarks,
        this.status,
        this.currency,
        this.product,
        this.productId,
        this.featureId,
        this.dateCreated,
        this.direction,
        this.transactionAmount});

  String getTransactionAmount() {
    var formatter = NumberFormat('###,###,###,##0.00');
    return "N${formatter.format(this.transactionAmount)}";
  }

  bool isCredit() {
    return direction == "C";
  }

  String getTitle() {
    return remarks != "N/A" ? remarks : product;
  }

  Activity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    remarks = json['remarks'];
    status = json['status'];
    currency = json['currency'];
    product = json['product'];
    productId = json['product_id'];
    featureId = json['feature_id'];
    dateCreated = json['date_created'];
    direction = json['direction'];
    transactionAmount = json['transaction_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['remarks'] = this.remarks;
    data['status'] = this.status;
    data['currency'] = this.currency;
    data['product'] = this.product;
    data['product_id'] = this.productId;
    data['feature_id'] = this.featureId;
    data['date_created'] = this.dateCreated;
    data['direction'] = this.direction;
    data['transaction_amount'] = this.transactionAmount;
    return data;
  }
}

