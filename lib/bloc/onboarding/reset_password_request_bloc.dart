
import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/reset_password_request_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class ResetPasswordRequestBloc extends Bloc {
  final _controller = StreamController<BaseResponse<ResetPasswordRequestResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<ResetPasswordRequestResponse>> get requestPassStream => _controller.stream;

  void requestPasswordRequest(String mobileNumber) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.resetPasswordInitialRequest(mobileNumber);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<ResetPasswordRequestResponse> loginResponse) {
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