class BanksListResponse {
  List<Bank> banks;
  String status;
  String statusCode;
  String message;

  BanksListResponse({this.banks, this.status, this.statusCode, this.message});

  BanksListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      banks = new List<Bank>();
      json['data'].forEach((v) {
        banks.add(new Bank.fromJson(v));
      });
    }
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.banks != null) {
      data['data'] = this.banks.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Bank {
  int id;
  String bankCode;
  String bankName;
  bool isMicrofinance;
  bool isActive;
  bool isMobileMoney;
  int countryId;
  String dateCreated;

  Bank(
      {this.id,
        this.bankCode,
        this.bankName,
        this.isMicrofinance,
        this.isActive,
        this.isMobileMoney,
        this.countryId,
        this.dateCreated});

  Bank.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
    isMicrofinance = json['is_microfinance'];
    isActive = json['is_active'];
    isMobileMoney = json['is_mobile_money'];
    countryId = json['country_id'];
    dateCreated = json['date_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['bank_code'] = this.bankCode;
    data['bank_name'] = this.bankName;
    data['is_microfinance'] = this.isMicrofinance;
    data['is_active'] = this.isActive;
    data['is_mobile_money'] = this.isMobileMoney;
    data['country_id'] = this.countryId;
    data['date_created'] = this.dateCreated;
    return data;
  }
}
