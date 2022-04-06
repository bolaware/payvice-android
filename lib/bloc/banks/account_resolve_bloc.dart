import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/banks_list_response.dart';
import 'package:payvice_app/data/response/send/account_resolve_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class AccountResolveBloc implements Bloc {
  final _controller = StreamController<BaseResponse<AccountResolveResponse>>();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<AccountResolveResponse>> get stream =>
      _controller.stream;

  void resolveAccountNumber(
      String accountNumber,
      String bankCode) async {
    final result = await _networkclient.resolveAccountNumber(accountNumber, bankCode);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<AccountResolveResponse> response) {
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