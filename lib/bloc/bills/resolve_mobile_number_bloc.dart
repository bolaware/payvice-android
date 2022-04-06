import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/banks_list_response.dart';
import 'package:payvice_app/data/response/bills/mobile_number_resolve_response.dart';
import 'package:payvice_app/data/response/send/account_resolve_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class ResolveMobileNumberBloc implements Bloc {
  final _controller = StreamController<BaseResponse<MobileNumberResolveResponse>>();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<MobileNumberResolveResponse>> get stream =>
      _controller.stream;

  void resolveAccountNumber(String accountNumber) async {
    final result = await _networkclient.resolveMobileNumber(accountNumber);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<MobileNumberResolveResponse> response) {
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