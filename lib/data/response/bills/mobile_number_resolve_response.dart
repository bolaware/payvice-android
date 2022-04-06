class MobileNumberResolveResponse {
  Data data;
  String status;
  String statusCode;
  String message;

  MobileNumberResolveResponse(
      {this.data, this.status, this.statusCode, this.message});

  MobileNumberResolveResponse.fromJson(Map<String, dynamic> json) {
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
  String provider;
  String validity;
  String number;

  Data({this.provider, this.validity, this.number});

  Data.fromJson(Map<String, dynamic> json) {
    provider = json['provider'];
    validity = json['validity'];
    number = json['number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['provider'] = this.provider;
    data['validity'] = this.validity;
    data['number'] = this.number;
    return data;
  }
}
