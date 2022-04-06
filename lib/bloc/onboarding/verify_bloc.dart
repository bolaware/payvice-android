import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class VerifyBloc extends Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<GenericResponse>> get stream =>
      _controller.stream;

  void verify(String bvn, String dob, String meansOfId, String idNumber) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.verify(bvn, dob, meansOfId, idNumber);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<GenericResponse> response) {
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