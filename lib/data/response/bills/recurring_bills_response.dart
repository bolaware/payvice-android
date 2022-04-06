import 'package:intl/intl.dart';

class RecurringBillsResponse {
  List<RecurringBillsData> data;
  String status;
  String statusCode;
  String message;

  RecurringBillsResponse(
      {this.data, this.status, this.statusCode, this.message});

  RecurringBillsResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = new List<RecurringBillsData>();
      json['data'].forEach((v) {
        data.add(new RecurringBillsData.fromJson(v));
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

class RecurringBillsData {
  String frequency;
  int id;
  int customerId;
  int productId;
  String type;
  String product;
  String logo;
  int productTransactionId;
  int frequencyId;
  String status;
  String payload;
  String uniqueReference;
  double amount;
  String beneficiaryNumber;
  Null sendReminder;
  Null dateLastReminderSent;
  String nextRun;
  int timeOfTheDay;
  String dateCreated;
  String dateUpdated;
  String dateDeleted;
  String dateLastRun;
  String dateStopped;

  RecurringBillsData(
      {this.frequency,
      this.id,
      this.customerId,
      this.productId,
        this.type,
        this.product,
        this.logo,
      this.productTransactionId,
      this.frequencyId,
      this.status,
      this.payload,
      this.uniqueReference,
      this.amount,
      this.beneficiaryNumber,
      this.sendReminder,
      this.dateLastReminderSent,
      this.nextRun,
      this.timeOfTheDay,
      this.dateCreated,
      this.dateUpdated,
      this.dateDeleted,
      this.dateLastRun,
      this.dateStopped});

  String getFormattedAmount() {
    var formatter = NumberFormat('###,###,###,##0.00');
    return formatter.format(this.amount);
  }

  String getFormatteDate() {
    var inputFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
    var inputDate = inputFormat.parse(this.dateCreated);

    var outputFormat = DateFormat('MMM dd,yyyy');
    var outputDate = outputFormat.format(inputDate);
    return outputDate;
  }

  String getSearchableValue() {
    return this.product.toLowerCase();
  }

  String getLogo() {
    return this.logo ?? "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png";
  }

  RecurringBillsData.fromJson(Map<String, dynamic> json) {
    frequency = json['frequency'];
    id = json['id'];
    type = json['type'];
    product = json['product'];
    logo = json['logo'];
    customerId = json['customer_id'];
    productId = json['product_id'];
    productTransactionId = json['product_transaction_id'];
    frequencyId = json['frequency_id'];
    status = json['status'];
    payload = json['payload'];
    uniqueReference = json['unique_reference'];
    amount = json['amount'];
    beneficiaryNumber = json['beneficiary_number'];
    sendReminder = json['send_reminder'];
    dateLastReminderSent = json['date_last_reminder_sent'];
    nextRun = json['next_run'];
    timeOfTheDay = json['time_of_the_day'];
    dateCreated = json['date_created'];
    dateUpdated = json['date_updated'];
    dateDeleted = json['date_deleted'];
    dateLastRun = json['date_last_run'];
    dateStopped = json['date_stopped'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['frequency'] = this.frequency;
    data['id'] = this.id;
    data['type'] = this.type;
    data['product'] = this.product;
    data['logo'] = this.logo;
    data['customer_id'] = this.customerId;
    data['product_id'] = this.productId;
    data['product_transaction_id'] = this.productTransactionId;
    data['frequency_id'] = this.frequencyId;
    data['status'] = this.status;
    data['payload'] = this.payload;
    data['unique_reference'] = this.uniqueReference;
    data['amount'] = this.amount;
    data['beneficiary_number'] = this.beneficiaryNumber;
    data['send_reminder'] = this.sendReminder;
    data['date_last_reminder_sent'] = this.dateLastReminderSent;
    data['next_run'] = this.nextRun;
    data['time_of_the_day'] = this.timeOfTheDay;
    data['date_created'] = this.dateCreated;
    data['date_updated'] = this.dateUpdated;
    data['date_deleted'] = this.dateDeleted;
    data['date_last_run'] = this.dateLastRun;
    data['date_stopped'] = this.dateStopped;
    return data;
  }
}
