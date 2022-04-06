class RequestsResponse {
  List<RequestsData> data;
  String status;
  String statusCode;
  String message;

  RequestsResponse({this.data, this.status, this.statusCode, this.message});

  RequestsResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RequestsData>[];
      json['data'].forEach((v) {
        data.add(new RequestsData.fromJson(v));
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

class RequestsData {
  String senderName;
  String beneficiaryName;
  String senderEmail;
  String beneficiaryEmail;
  String currency;
  String acceptedCurrency;
  String answerName;
  String statusName;
  int id;
  int customerId;
  int fromCustomerId;
  int currencyId;
  int acceptedCurrencyId;
  double amount;
  double acceptedAmount;
  String dateRequested;
  String dateAcceptedOrRejected;
  String requestReason;
  String acceptOrRejectReason;
  String payReference;
  String dateUpdated;
  int answer;
  int status;
  int goalId;

  RequestsData(
      {this.senderName,
      this.beneficiaryName,
      this.senderEmail,
      this.beneficiaryEmail,
      this.currency,
      this.acceptedCurrency,
      this.answerName,
      this.statusName,
      this.id,
      this.customerId,
      this.fromCustomerId,
      this.currencyId,
      this.acceptedCurrencyId,
      this.amount,
      this.acceptedAmount,
      this.dateRequested,
      this.dateAcceptedOrRejected,
      this.requestReason,
      this.acceptOrRejectReason,
      this.payReference,
      this.dateUpdated,
      this.answer,
      this.status,
      this.goalId});

  RequestsData.fromJson(Map<String, dynamic> json) {
    senderName = json['sender_name'];
    beneficiaryName = json['beneficiary_name'];
    senderEmail = json['sender_email'];
    beneficiaryEmail = json['beneficiary_email'];
    currency = json['currency'];
    acceptedCurrency = json['accepted_currency'];
    answerName = json['answer_name'];
    statusName = json['status_name'];
    id = json['id'];
    customerId = json['customer_id'];
    fromCustomerId = json['from_customer_id'];
    currencyId = json['currency_id'];
    acceptedCurrencyId = json['accepted_currency_id'];
    amount = json['amount'];
    acceptedAmount = json['accepted_amount'];
    dateRequested = json['date_requested'];
    dateAcceptedOrRejected = json['date_accepted_or_rejected'];
    requestReason = json['request_reason'];
    acceptOrRejectReason = json['accept_or_reject_reason'];
    payReference = json['pay_reference'];
    dateUpdated = json['date_updated'];
    answer = json['answer'];
    status = json['status'];
    goalId = json['goal_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sender_name'] = this.senderName;
    data['beneficiary_name'] = this.beneficiaryName;
    data['sender_email'] = this.senderEmail;
    data['beneficiary_email'] = this.beneficiaryEmail;
    data['currency'] = this.currency;
    data['accepted_currency'] = this.acceptedCurrency;
    data['answer_name'] = this.answerName;
    data['status_name'] = this.statusName;
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['from_customer_id'] = this.fromCustomerId;
    data['currency_id'] = this.currencyId;
    data['accepted_currency_id'] = this.acceptedCurrencyId;
    data['amount'] = this.amount;
    data['accepted_amount'] = this.acceptedAmount;
    data['date_requested'] = this.dateRequested;
    data['date_accepted_or_rejected'] = this.dateAcceptedOrRejected;
    data['request_reason'] = this.requestReason;
    data['accept_or_reject_reason'] = this.acceptOrRejectReason;
    data['pay_reference'] = this.payReference;
    data['date_updated'] = this.dateUpdated;
    data['answer'] = this.answer;
    data['status'] = this.status;
    data['goal_id'] = this.goalId;
    return data;
  }
}
