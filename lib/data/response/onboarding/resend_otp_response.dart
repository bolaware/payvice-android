class ResendOtpResponse {
  ResendOtp resendOtp;
  String status;
  String statusCode;
  String message;

  ResendOtpResponse({this.resendOtp, this.status, this.statusCode, this.message});

  ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    resendOtp = json['resend_otp'] != null
        ? new ResendOtp.fromJson(json['resend_otp'])
        : null;
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.resendOtp != null) {
      data['resend_otp'] = this.resendOtp.toJson();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ResendOtp {
  String otpPrefix;

  ResendOtp({this.otpPrefix});

  ResendOtp.fromJson(Map<String, dynamic> json) {
    otpPrefix = json['otp_prefix'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['otp_prefix'] = this.otpPrefix;
    return data;
  }
}