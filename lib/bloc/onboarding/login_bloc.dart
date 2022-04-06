import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class LoginBloc implements Bloc {
  final _controller = StreamController<BaseResponse<LoginResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<LoginResponse>> get stream =>
      _controller.stream;

  void loginWithPhoneNumber(String dialCode, String phoneNumber, String password) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.loginWithMobileNumber(
        "$dialCode$phoneNumber",
        password
    );
    if(result is Success) {
      cache.clearBiometric();
      var customer = (result as Success<LoginResponse>).getData().customer;
      cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
      cache.saveIdentifier(jsonEncode(Identifier(identifier: customer.mobileNumber, isPhoneMode: true, firstName: customer.firstName).toJson()));
    }
    _controller.sink.add(result);
  }

  void loginWithEmail(String email, String password) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.loginWithEmail(email, password);
    if(result is Success) {
      cache.clearBiometric();
      var customer = (result as Success<LoginResponse>).getData().customer;
      cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
      cache.saveIdentifier(jsonEncode(Identifier(identifier: customer.mobileNumber, isPhoneMode: true, firstName: customer.firstName).toJson()));
    }
    _controller.sink.add(result);
  }

  void loginWithPin(String mobileNumber, String pin) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.loginWithPin(mobileNumber, pin);
    if(result is Success) {
      cache.clearBiometric();
      var customer = (result as Success<LoginResponse>).getData().customer;
      cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
      cache.saveIdentifier(jsonEncode(Identifier(identifier: customer.mobileNumber, isPhoneMode: true, firstName: customer.firstName).toJson()));
    }
    _controller.sink.add(result);
  }

  void loginWithBiometric(String identifier) async {
    _controller.sink.add(showLoading());
    final pin = await cache.getPass();
    final result = await _networkclient.loginWithPin(identifier, pin);
    if(result is Success) {
      var customer = (result as Success<LoginResponse>).getData().customer;
      cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
      cache.saveIdentifier(jsonEncode(Identifier(identifier: customer.mobileNumber, isPhoneMode: true, firstName: customer.firstName).toJson()));
    }
    _controller.sink.add(result);
  }

  Future<void> savePin(String pin) async {
    await cache.savePass(pin);
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