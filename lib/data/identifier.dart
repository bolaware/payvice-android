class Identifier {
  String identifier;
  bool isPhoneMode;
  String firstName;

  Identifier({this.identifier, this.isPhoneMode, this.firstName});

  Identifier.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    isPhoneMode = json['is_phone_mode'];
    firstName = json['first_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['identifier'] = this.identifier;
    data['is_phone_mode'] = this.isPhoneMode;
    data['first_name'] = this.firstName;
    return data;
  }
}