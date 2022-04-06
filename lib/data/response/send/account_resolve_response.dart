class AccountResolveResponse {
  Data data;
  String status;
  String statusCode;
  String message;

  AccountResolveResponse(
      {this.data, this.status, this.statusCode, this.message});

  AccountResolveResponse.fromJson(Map<String, dynamic> json) {
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
  String bankName;
  String bankCode;
  String accountNumber;
  String accountName;

  Data({this.bankName, this.bankCode, this.accountNumber, this.accountName});

  Data.fromJson(Map<String, dynamic> json) {
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    data['account_number'] = this.accountNumber;
    data['account_name'] = this.accountName;
    return data;
  }
}
