import 'dart:async';
import 'dart:convert';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SetBiometricBloc implements Bloc {

  final _controller = StreamController<BaseResponse<LoginResponse>>();
  final _networkclient = Network();
  final _cache = Cache();
  Stream<BaseResponse<LoginResponse>> get setPinStream => _controller.stream;

  var tempPin = "";

  void loginWithPin(String pin) async {
    _controller.sink.add(showLoading());
    final cachedData = await _cache.getCustomerData();
    LoginResponse me = LoginResponse.fromJson(json.decode(cachedData));
    final response = await _networkclient.loginWithPin(me.customer.mobileNumber, pin);
    tempPin = pin;
    _controller.sink.add(response);
  }

  Future<void> savePin(String pin) async {
    await _cache.savePass(pin);
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
