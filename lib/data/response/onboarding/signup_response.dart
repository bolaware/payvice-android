class SignupResponse {
  Signup signup;
  String status;
  String statusCode;
  String message;

  SignupResponse({this.signup, this.status, this.statusCode, this.message});

  String _formattedPhone;

  SignupResponse setFormattedPhone(String formattedPhone) {
    _formattedPhone = formattedPhone;
    return this;
  }

  String getFormattedPhone() {
    return _formattedPhone;
  }

  SignupResponse.fromJson(Map<String, dynamic> json) {
    signup =
    json['signup'] != null ? new Signup.fromJson(json['signup']) : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.signup != null) {
      data['signup'] = this.signup.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Signup {
  String otpPrefix;
  String action;

  Signup({this.otpPrefix, this.action});

  Signup.fromJson(Map<String, dynamic> json) {
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