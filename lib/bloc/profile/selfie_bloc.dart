import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SelfieBloc implements Bloc {
  final _controller = StreamController<BaseResponse<bool>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<bool>> get stream =>
      _controller.stream;

  void createVerificationSession() async {
    final result = await _networkclient.createVerificationSession();
  }

  void uploadSelfie(String imageFilePath) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.uploadSelfie(imageFilePath);
    print(result);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<bool> response) {
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