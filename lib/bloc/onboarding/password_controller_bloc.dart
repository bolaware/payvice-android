import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/validators.dart';

class PasswordControllerBloc implements Bloc {

  final _controller = StreamController<PasswordValidatorCheck>();
  Stream<PasswordValidatorCheck> get stream => _controller.stream;

  void setPassword(String password) {
    var checks = Validators.isPasswordValidCheck(password);
    _controller.sink.add(checks);
  }

  @override
  void dispose() {
    print("DISPOSED");
    _controller.close();
  }

  @override
  Loading<T> showLoading<T>() {
    return null;
  }
}
