import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';
import 'dart:async';

class UpdateProfileBloc implements Bloc {

  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<GenericResponse>> get stream => _controller.stream;

  void updateProfile(
      String fullName,
      String dob,
      String username,
      String referralCode) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.updateProfile(
      fullName, dob, username, referralCode
    );
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