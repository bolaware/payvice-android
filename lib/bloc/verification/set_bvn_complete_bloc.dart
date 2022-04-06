

import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SetBvnCompleteBloc implements Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<GenericResponse>> get phoneVerificationStream =>
      _controller.stream;

  void confirmOtp(
      String otp,
      String otpPrefix,
      String mobileNumber) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.otpBvnConfirm(otp, otpPrefix);
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