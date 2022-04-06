import 'package:intl/intl.dart';

class SuccessResponse {
  Data data;
  String status;
  String statusCode;
  String message;

  SuccessResponse({this.data, this.status, this.statusCode, this.message});

  SuccessResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  double amount;
  int currencyId;
  String dateCreated;
  int customerId;
  int transactionId;
  String remarks;
  String transactionReference;
  int statusId;
  String responseCode;
  String payReference;
  String responseMessage;
  String direction;

  Data(
      {this.amount,
        this.currencyId,
        this.dateCreated,
        this.customerId,
        this.transactionId,
        this.remarks,
        this.transactionReference,
        this.statusId,
        this.responseCode,
        this.payReference,
        this.responseMessage,
        this.direction});

  String getFormatteDate() {
    var inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
    var inputDate = inputFormat.parse(this.dateCreated);

    var outputFormat = DateFormat('MMM dd,yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  Data.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currencyId = json['currency_id'];
    dateCreated = json['date_created'];
    customerId = json['customer_id'];
    transactionId = json['transaction_id'];
    remarks = json['remarks'];
    transactionReference = json['transaction_reference'];
    statusId = json['status_id'];
    responseCode = json['response_code'];
    payReference = json['pay_reference'];
    responseMessage = json['response_message'];
    direction = json['direction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['currency_id'] = this.currencyId;
    data['date_created'] = this.dateCreated;
    data['customer_id'] = this.customerId;
    data['transaction_id'] = this.transactionId;
    data['remarks'] = this.remarks;
    data['transaction_reference'] = this.transactionReference;
    data['status_id'] = this.statusId;
    data['response_code'] = this.responseCode;
    data['pay_reference'] = this.payReference;
    data['response_message'] = this.responseMessage;
    data['direction'] = this.direction;
    return data;
  }
}
