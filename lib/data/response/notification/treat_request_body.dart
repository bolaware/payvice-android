class TreatRequestBody {
  String answer;
  int requestId;
  String transactionPin;
  String acceptedAmount;
  String message;

  TreatRequestBody(
      {this.answer,
      this.requestId,
      this.transactionPin,
      this.acceptedAmount,
      this.message});

  TreatRequestBody.fromJson(Map<String, dynamic> json) {
    answer = json['answer'];
    requestId = json['request_id'];
    transactionPin = json['transaction_pin'];
    acceptedAmount = json['accepted_amount'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['answer'] = this.answer;
    data['request_id'] = this.requestId;
    data['transaction_pin'] = this.transactionPin;
    data['accepted_amount'] = this.acceptedAmount;
    data['message'] = this.message;
    return data;
  }
}
