import 'dart:async';
import 'dart:convert';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/signup_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SignupBloc implements Bloc {
  final _controller = StreamController<BaseResponse<SignupResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<SignupResponse>> get signUpResponseStream =>
      _controller.stream;

  void signUp(
      String mobileNumber,
      String emailAddress,
      String password) async {
    _controller.sink.add(showLoading());
    final result = await
      _networkclient.signUp(mobileNumber,emailAddress,password);
    if(result is Success) {
      await cache.saveIdentifier(
          jsonEncode(
              Identifier(
                  identifier: mobileNumber,
                  isPhoneMode: true,
                  firstName: ""
              ).toJson())
      );
      await cache.clearBiometric();
    }
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<SignupResponse> signUpResponse) {
    _controller.sink.add(signUpResponse.clone());
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