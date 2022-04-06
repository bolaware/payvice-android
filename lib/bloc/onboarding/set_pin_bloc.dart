import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SetPinBloc implements Bloc {

  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  final _cache = Cache();
  Stream<BaseResponse<GenericResponse>> get setPinStream => _controller.stream;

  void setPin(String pin) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.setPin(pin);
    _controller.sink.add(result);
  }

  Future<void> savePin(String pin) async {
    await _cache.savePass(pin);
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
