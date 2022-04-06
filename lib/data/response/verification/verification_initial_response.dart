class BvnVerificationInitialResponse {
  ValidateBvn validateBvn;
  String status;
  String statusCode;
  String message;

  BvnVerificationInitialResponse(
      {this.validateBvn, this.status, this.statusCode, this.message});

  BvnVerificationInitialResponse.fromJson(Map<String, dynamic> json) {
    validateBvn = json['validate_bvn'] != null
        ? new ValidateBvn.fromJson(json['validate_bvn'])
        : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  String _formattedPhone;

  BvnVerificationInitialResponse setFormattedPhone(String formattedPhone) {
    _formattedPhone = formattedPhone;
    return this;
  }

  String getFormattedPhone() {
    return _formattedPhone;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.validateBvn != null) {
      data['validate_bvn'] = this.validateBvn.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ValidateBvn {
  String otpPrefix;
  String action;

  ValidateBvn({this.otpPrefix, this.action});

  ValidateBvn.fromJson(Map<String, dynamic> json) {
    otpPrefix = json['otp_prefix'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp_prefix'] = this.otpPrefix;
    data['action'] = this.action;
    return data;
  }
}
