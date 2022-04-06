class ResetPasswordRequestResponse {
  PasswordReset passwordReset;
  String status;
  String statusCode;
  String message;

  String _formattedPhone;

  ResetPasswordRequestResponse(
      {this.passwordReset, this.status, this.statusCode, this.message});

  ResetPasswordRequestResponse.fromJson(Map<String, dynamic> json) {
    passwordReset = json['password_reset'] != null
        ? new PasswordReset.fromJson(json['password_reset'])
        : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }


  ResetPasswordRequestResponse setFormattedPhone(String formattedPhone) {
    _formattedPhone = formattedPhone;
    return this;
  }

  String getFormattedPhone() {
    return _formattedPhone;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.passwordReset != null) {
      data['password_reset'] = this.passwordReset.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class PasswordReset {
  String otpPrefix;
  String action;

  PasswordReset({this.otpPrefix, this.action});

  PasswordReset.fromJson(Map<String, dynamic> json) {
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