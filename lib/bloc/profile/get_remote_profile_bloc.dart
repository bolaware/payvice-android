import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';
import 'package:rxdart/subjects.dart';

class GetRemoteProfileBloc implements Bloc {
  final _controller = BehaviorSubject<BaseResponse<LoginResponse>>();
  final cache = Cache();
  final network = Network();

  Stream<BaseResponse<LoginResponse>> get stream =>
      _controller.stream;

  void getProfile() async {
    final result = await network.getProfile();
    _controller.sink.add(result);
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