import 'package:intl/intl.dart';

class LoginResponse {
  Customer customer;
  List<Balance> balances;
  Verification verification;
  AccountNumber accountNumber;
  List<Preferences> preferences;
  Token token;
  String status;
  String statusCode;
  String message;

  LoginResponse(
      {this.customer,
        this.balances,
        this.token,
        this.accountNumber,
        this.status,
        this.verification,
        this.preferences,
        this.statusCode,
        this.message});

  LoginResponse.fromJson(Map<String, dynamic> json) {
    customer = json['customer'] != null
        ? new Customer.fromJson(json['customer'])
        : null;
    if (json['balances'] != null) {
      balances = new List<Balance>();
      json['balances'].forEach((v) {
        balances.add(new Balance.fromJson(v));
      });
    }
    if (json['preferences'] != null) {
      preferences = new List<Preferences>();
      json['preferences'].forEach((v) {
        preferences.add(new Preferences.fromJson(v));
      });
    }
    verification = json['verification'] != null
        ? new Verification.fromJson(json['verification'])
        : null;
    token = json['token'] != null ? new Token.fromJson(json['token']) : null;
    accountNumber = json['account_number'] != null
        ? new AccountNumber.fromJson(json['account_number'])
        : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.customer != null) {
      data['customer'] = this.customer.toJson();
    }
    if (this.balances != null) {
      data['balances'] = this.balances.map((v) => v.toJson()).toList();
    }
    if (this.preferences != null) {
      data['preferences'] = this.preferences.map((v) => v.toJson()).toList();
    }
    if (this.token != null) {
      data['token'] = this.token.toJson();
    }
    if (this.accountNumber != null) {
      data['account_number'] = this.accountNumber.toJson();
    }
    if (this.verification != null) {
      data['verification'] = this.verification.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class AccountNumber {
  int id;
  String nuban;
  String bankName;
  String bankCode;

  AccountNumber({this.id, this.nuban, this.bankName, this.bankCode});

  AccountNumber.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nuban = json['nuban'];
    bankName = json['bank_name'];
    bankCode = json['bank_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nuban'] = this.nuban;
    data['bank_name'] = this.bankName;
    data['bank_code'] = this.bankCode;
    return data;
  }
}

class Preferences {
  int id;
  int customerId;
  String preferenceName;
  Null description;
  String value;
  bool isActive;
  String dateCreated;
  String dateUpdated;

  Preferences(
      {this.id,
        this.customerId,
        this.preferenceName,
        this.description,
        this.value,
        this.isActive,
        this.dateCreated,
        this.dateUpdated});

  Preferences.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customer_id'];
    preferenceName = json['preference_name'];
    description = json['description'];
    value = json['value'];
    isActive = json['is_active'];
    dateCreated = json['date_created'];
    dateUpdated = json['date_updated'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['customer_id'] = this.customerId;
    data['preference_name'] = this.preferenceName;
    data['description'] = this.description;
    data['value'] = this.value;
    data['is_active'] = this.isActive;
    data['date_created'] = this.dateCreated;
    data['date_updated'] = this.dateUpdated;
    return data;
  }
}

class Customer {
  int id;
  String firstName;
  String middleName;
  String lastName;
  String dateOfBirth;
  String mobileNumber;
  String emailAddress;
  String address;
  String avatar;

  Customer(
      {this.id,
        this.firstName,
        this.middleName,
        this.lastName,
        this.dateOfBirth,
        this.mobileNumber,
        this.emailAddress,
        this.address,
        this.avatar
      });


  DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss");
  DateFormat outputFormat = DateFormat("MMM d, yyyy");

  String getFormattedDOB() {
    DateTime dateTime = getDateInstance();
    return outputFormat.format(dateTime);
  }

  String getAvatar() {
    return avatar != null ? avatar : "";
  }

  DateTime getDateInstance() {
    return dateFormat.parse(dateOfBirth);
  }

  Customer.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    dateOfBirth = json['date_of_birth'];
    mobileNumber = json['mobile_number'];
    emailAddress = json['email_address'];
    address = json['address'];
    avatar = json['avatar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['date_of_birth'] = this.dateOfBirth;
    data['mobile_number'] = this.mobileNumber;
    data['email_address'] = this.emailAddress;
    data['address'] = this.address;
    data['avatar'] = this.avatar;
    return data;
  }
}

class Balance {
  String currency;
  double availableBalance;
  double ledgerBalance;
  String nickName;
  String type;

  Balance(
      {this.currency,
        this.availableBalance,
        this.ledgerBalance,
        this.nickName,
        this.type});

  String getFomrattedBalance() {
    var formatter = NumberFormat('###,###,###,##0.00');
    return formatter.format(this.availableBalance);
  }

  Balance.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    availableBalance = json['available_balance'];
    ledgerBalance = json['ledger_balance'];
    nickName = json['nick_name'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currency'] = this.currency;
    data['available_balance'] = this.availableBalance;
    data['ledger_balance'] = this.ledgerBalance;
    data['nick_name'] = this.nickName;
    data['type'] = this.type;
    return data;
  }
}

class Token {
  String accessToken;

  Token({this.accessToken});

  Token.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    return data;
  }
}

class Verification {
  String bvn;
  String mobileNumber;
  String emailAddress;
  String bvnVerificationStatus;
  bool isMobileVerified;
  bool isEmailVerified;
  String customerStatus;
  Null nin;
  Null ninStatus;

  Verification(
      {this.bvn,
        this.mobileNumber,
        this.emailAddress,
        this.bvnVerificationStatus,
        this.isMobileVerified,
        this.isEmailVerified,
        this.customerStatus,
        this.nin,
        this.ninStatus});

  Verification.fromJson(Map<String, dynamic> json) {
    bvn = json['bvn'];
    mobileNumber = json['mobile_number'];
    emailAddress = json['email_address'];
    bvnVerificationStatus = json['bvn_verification_status'];
    isMobileVerified = json['is_mobile_verified'];
    isEmailVerified = json['is_email_verified'];
    customerStatus = json['customer_status'];
    nin = json['nin'];
    ninStatus = json['nin_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bvn'] = this.bvn;
    data['mobile_number'] = this.mobileNumber;
    data['email_address'] = this.emailAddress;
    data['bvn_verification_status'] = this.bvnVerificationStatus;
    data['is_mobile_verified'] = this.isMobileVerified;
    data['is_email_verified'] = this.isEmailVerified;
    data['customer_status'] = this.customerStatus;
    data['nin'] = this.nin;
    data['nin_status'] = this.ninStatus;
    return data;
  }
}
