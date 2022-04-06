import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/resend_otp_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class VerificationRequestBloc implements Bloc {
  final _controller = StreamController<BaseResponse<ResendOtpResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<ResendOtpResponse>> get phoneVerificationStream =>
      _controller.stream;

  void requestOtp(
      String previousOtpPrefix,
      String mobileNumber) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.resendOtp(previousOtpPrefix, mobileNumber);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<ResendOtpResponse> loginResponse) {
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