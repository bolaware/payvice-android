import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';
import 'dart:async';

class ChangePassBloc implements Bloc {

  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<GenericResponse>> get stream => _controller.stream;

  void changePassword(String oldPass, String newPass) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.changePassword(oldPass, newPass);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<GenericResponse> loginResponse) {
    _controller.sink.add(loginResponse.clone());
  }

  @override
  void dispose() {
    print("DISPOSED");
    _controller.close();
  }


  @override
  Loading<T> showLoading<T>() {
    return Loading();
  }
}