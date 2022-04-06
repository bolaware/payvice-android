import 'package:payvice_app/data/local_contact.dart';

class ContactsResponse {
  List<FriendData> friendData;
  String status;
  String statusCode;
  String message;

  ContactsResponse(
      {this.friendData, this.status, this.statusCode, this.message});

  ContactsResponse.fromJson(Map<String, dynamic> json) {
    if (json['friend_data'] != null) {
      friendData = new List<FriendData>();
      json['friend_data'].forEach((v) {
        friendData.add(new FriendData.fromJson(v));
      });
    }
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.friendData != null) {
      data['friend_data'] = this.friendData.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class FriendData implements LocalContact {
  String avatar;
  String firstName;
  String lastName;
  String status;
  String countryName;
  String countryShortName;
  String mobileNumber;

  FriendData(
      {this.avatar,
        this.firstName,
        this.lastName,
        this.status,
        this.countryName,
        this.countryShortName,
        this.mobileNumber});

  @override
  String getSearchableValue() {
    return (this.firstName+this.lastName+this.mobileNumber).toLowerCase();
  }

  FriendData.fromJson(Map<String, dynamic> json) {
    avatar = json['avatar'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    status = json['status'];
    countryName = json['country_name'];
    countryShortName = json['country_short_name'];
    mobileNumber = json['mobile_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['avatar'] = this.avatar;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['status'] = this.status;
    data['country_name'] = this.countryName;
    data['country_short_name'] = this.countryShortName;
    data['mobile_number'] = this.mobileNumber;
    return data;
  }
}
