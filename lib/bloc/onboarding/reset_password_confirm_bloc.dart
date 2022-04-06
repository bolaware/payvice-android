
import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';
import 'package:flutter/material.dart';

class ResetPasswordConfirmBloc extends Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<GenericResponse>> get requestPassStream => _controller.stream;

  void requestPasswordRequest(String mobileNumber, String otpPrefix, String otp, String password) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.resetPasswordConfirmationRequest(
      mobileNumber, otpPrefix, otp, password
    );
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<GenericResponse> loginResponse) {
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
