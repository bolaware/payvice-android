import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';

class IsBiometricEnrolledBloc implements Bloc {

  final _controller = StreamController<bool>.broadcast();
  final cache = Cache();

  Stream<bool> get stream =>
      _controller.stream;

  void isBiometricEnabled() async {
    final isEnrolled = await cache.getBiometricEnrolled();

    print("fffhfhhfhfhhhf 1 $isEnrolled");

    _controller.sink.add(isEnrolled);
  }

  void enableBiometrics(bool enable) {
    _controller.sink.add(enable);
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