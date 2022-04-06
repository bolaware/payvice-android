import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class RequestStatementBloc implements Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();

  Stream<BaseResponse<GenericResponse>> get stream =>
      _controller.stream;

  void requestStatement(String from, String to) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.requestStatement(from, to);
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