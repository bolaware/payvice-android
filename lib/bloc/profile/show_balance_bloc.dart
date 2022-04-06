import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';

class ShowBalanceBloc implements Bloc {

  final _controller = StreamController<bool>.broadcast();
  final cache = Cache();

  Stream<bool> get stream =>
      _controller.stream;

  void getShowBalanceVisibility() async {
    final isEnrolled = await cache.sholdShowBalanceEnrolled();

    _controller.sink.add(isEnrolled);
  }

  void switchVisibility() async {
    final isEnrolled = await cache.sholdShowBalanceEnrolled();

    cache.saveShouldShowBalanceEnrolled(!isEnrolled);

    _controller.sink.add(!isEnrolled);
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