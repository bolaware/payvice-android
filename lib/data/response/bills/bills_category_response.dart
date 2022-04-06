class BillsCategoryResponse {
  List<BillCategory> categories;
  String status;
  String responseCode;
  String responseMessage;

  BillsCategoryResponse(
      {this.categories, this.status, this.responseCode, this.responseMessage});

  BillsCategoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = new List<BillCategory>();
      json['categories'].forEach((v) {
        categories.add(new BillCategory.fromJson(v));
      });
    }
    status = json['status'];
    responseCode = json['response_code'];
    responseMessage = json['response_message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories.map((v) => v.toJson()).toList();
    }
    data['status'] = this.status;
    data['response_code'] = this.responseCode;
    data['response_message'] = this.responseMessage;
    return data;
  }
}

class BillCategory {
  String code;
  String name;
  String description;
  String fieldName;
  String country;
  String countryCode;
  String image;

  BillCategory({this.code,
    this.name,
    this.description,
    this.fieldName,
    this.country,
    this.countryCode,
    this.image});

  BillCategory.createDummy() {
    code = null;
    name = null;
    description = null;
    fieldName = null;
    country = null;
    countryCode = null;
    image = null;
  }

  String getFieldName() {
    return fieldName ?? "Customer ID";
  }

  BillCategory.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    description = json['description'];
    fieldName = json['field_name'];
    country = json['country'];
    countryCode = json['country_code'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['field_name'] = this.fieldName;
    data['description'] = this.description;
    data['country'] = this.country;
    data['country_code'] = this.countryCode;
    data['image'] = this.image;
    return data;
  }
}
