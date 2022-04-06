class BankBeneficiaryResponse {
  List<Beneficiary> beneficaries;
  String status;
  String statusCode;
  String message;

  BankBeneficiaryResponse(
      {this.beneficaries, this.status, this.statusCode, this.message});

  BankBeneficiaryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      beneficaries = new List<Beneficiary>();
      json['data'].forEach((v) {
        beneficaries.add(new Beneficiary.fromJson(v));
      });
    }
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.beneficaries != null) {
      data['data'] = this.beneficaries.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Beneficiary {
  int id;
  int customerId;
  int beneficiaryCustomerId;
  String beneficiaryNickName;
  String destination;
  String beneficiaryFullName;
  String beneficiaryEmail;
  String accountDetail;
  String bankCode;
  String bankName;
  String currency;
  String country;
  int countryId;
  int currencyId;
  double lastPaymentAmount;
  String dateCreated;
  String lastPaymentDate;

  Beneficiary(
      {this.id,
        this.customerId,
        this.beneficiaryCustomerId,
        this.beneficiaryNickName,
        this.destination,
        this.beneficiaryFullName,
        this.beneficiaryEmail,
        this.accountDetail,
        this.bankCode,
        this.bankName,
        this.currency,
        this.country,
        this.countryId,
        this.currencyId,
        this.lastPaymentAmount,
        this.dateCreated,
        this.lastPaymentDate});

  Beneficiary.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    beneficiaryCustomerId = json['beneficiary_customer_id'];
    beneficiaryNickName = json['beneficiary_nick_name'];
    destination = json['destination'];
    beneficiaryFullName = json['beneficiary_full_name'];
    beneficiaryEmail = json['beneficiary_email'];
    accountDetail = json['account_detail'];
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
    currency = json['currency'];
    country = json['country'];
    countryId = json['country_id'];
    currencyId = json['currency_id'];
    lastPaymentAmount = json['last_payment_amount'];
    dateCreated = json['date_created'];
    lastPaymentDate = json['last_payment_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['beneficiary_customer_id'] = this.beneficiaryCustomerId;
    data['beneficiary_nick_name'] = this.beneficiaryNickName;
    data['destination'] = this.destination;
    data['beneficiary_full_name'] = this.beneficiaryFullName;
    data['beneficiary_email'] = this.beneficiaryEmail;
    data['account_detail'] = this.accountDetail;
    data['bank_code'] = this.bankCode;
    data['bank_name'] = this.bankName;
    data['currency'] = this.currency;
    data['country'] = this.country;
    data['country_id'] = this.countryId;
    data['currency_id'] = this.currencyId;
    data['last_payment_amount'] = this.lastPaymentAmount;
    data['date_created'] = this.dateCreated;
    data['last_payment_date'] = this.lastPaymentDate;
    return data;
  }
}