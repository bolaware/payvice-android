import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:rxdart/subjects.dart';

class GetCacheProfileBloc implements Bloc {

  final _controller = StreamController<BaseResponse<LoginResponse>>();
  final cache = Cache();

  Stream<BaseResponse<LoginResponse>> get stream =>
      _controller.stream;

  void getProfile() async {
    final cachedData = await cache.getCustomerData();

    BaseResponse<LoginResponse> response;

    if(cachedData != null) {
      response = Success(LoginResponse.fromJson(json.decode(cachedData)));
    } else {
      response = Error(GenericResponse());
    }

    _controller.sink.add(response);
  }

  void hasReadData(BaseResponse<LoginResponse> loginResponse) {
    _controller.sink.add(loginResponse.clone());
  }

  @override
  Loading<T> showLoading<T>() {
    return Loading();
  }

  @override
  void dispose() {
    print("DISPOSED");
    _controller.close();
  }
}