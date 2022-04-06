import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/signup_response.dart';
import 'package:payvice_app/data/response/verification/verification_initial_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class SetBvnBloc implements Bloc {

  final _controller = StreamController<BaseResponse<BvnVerificationInitialResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<BvnVerificationInitialResponse>> get stream => _controller.stream;


  void setBvn(String bvn, String dob) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.setBvn(bvn, dob);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<BvnVerificationInitialResponse> loginResponse) {
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
