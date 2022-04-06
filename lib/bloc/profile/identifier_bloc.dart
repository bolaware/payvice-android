import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';

class IdentifierBloc implements Bloc {

  final _controller = StreamController<BaseResponse<Identifier>>.broadcast();
  final cache = Cache();

  Stream<BaseResponse<Identifier>> get stream =>
      _controller.stream;

  void getIdentifier() async {
    final cachedData = await cache.getIdentifier();

    if(cachedData == null) {
      _controller.sink.add(Error(GenericResponse()));
    } else {
      _controller.sink.add(Success(Identifier.fromJson(jsonDecode(cachedData))));
    }
  }

  void setTempPhoneMode(isPhoneMode) async {
    _controller.sink.add(Success(Identifier(identifier: "", isPhoneMode: isPhoneMode)));
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