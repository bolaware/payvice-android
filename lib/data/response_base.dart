
class BaseResponse<T>{
  bool hasReadData = false;

  BaseResponse<T> clone() {
    hasReadData = true;
    return this;
  }
}


class Success<T> extends BaseResponse<T> {

  T _data;

  Success(T data) {
    this._data = data;
  }

  T getData() {
    return _data;
  }
}

class Error<T> extends BaseResponse<T> {

  GenericResponse _error;

  Error(GenericResponse error) {
    this._error = error;
  }

  GenericResponse getError() {
    return _error;
  }
}

class Loading<T> extends BaseResponse<T> { }

class GenericResponse {
  String status;
  String statusCode;
  String message;
  String prefix;
  String action;

  GenericResponse({this.status, this.statusCode, this.message});

  GenericResponse.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusCode = json['status_code'];
    message = json['message'];
    prefix = json['prefix'];
    action = json['action'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['status_code'] = this.statusCode;
    data['message'] = this.message;
    data['prefix'] = this.prefix;
    data['action'] = this.action;
    return data;
  }
}