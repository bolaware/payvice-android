class NotificationResponse {
  List<NotificationData> data;
  String status;
  String statusCode;
  String message;

  NotificationResponse({this.data, this.status, this.statusCode, this.message});

  NotificationResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data.add(new NotificationData.fromJson(v));
      });
    }
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class NotificationData {
  int id;
  String pushMessage;
  String messageTitle;
  int deviceId;
  Null isRead;
  Null dateRead;
  int customerId;
  String dateCreated;
  String additionalData;

  NotificationData(
      {this.id,
      this.pushMessage,
      this.messageTitle,
      this.deviceId,
      this.isRead,
      this.dateRead,
      this.customerId,
      this.dateCreated,
      this.additionalData});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pushMessage = json['push_message'];
    messageTitle = json['message_title'];
    deviceId = json['device_id'];
    isRead = json['is_read'];
    dateRead = json['date_read'];
    customerId = json['customer_id'];
    dateCreated = json['date_created'];
    additionalData = json['additional_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['push_message'] = this.pushMessage;
    data['message_title'] = this.messageTitle;
    data['device_id'] = this.deviceId;
    data['is_read'] = this.isRead;
    data['date_read'] = this.dateRead;
    data['customer_id'] = this.customerId;
    data['date_created'] = this.dateCreated;
    data['additional_data'] = this.additionalData;
    return data;
  }
}
