import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SelfieBloc implements Bloc {
  final _controller = StreamController<BaseResponse<LoginResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<LoginResponse>> get stream =>
      _controller.stream;

  void uploadSelfie(String imageFilePath) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.uploadSelfie(imageFilePath);
    if(result is Success) {
      print("%%%%%%%%%%%%%%%%%%%%%");
      // TO-DO Remove this delay here, tell BE there is a delay in getting bk correct dp
      await Future.delayed(Duration(seconds: 2));
      _controller.sink.add(await _networkclient.getProfile());
    } else {
      _controller.sink.add(Error<LoginResponse>((result as Error<bool>).getError()));
    }
  }

  void hasReadData(BaseResponse<LoginResponse> response) {
    _controller.sink.add(response.clone());
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