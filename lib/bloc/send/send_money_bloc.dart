import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class SendMoneyBloc implements Bloc {
  final _controller = StreamController<BaseResponse<SuccessResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<SuccessResponse>> get stream =>
      _controller.stream;

  void sendMoneyToAccount(
      String pin,
      String amount,
      String note,
      String accountNumber,
      String accountName,
      String bankCode
      ) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.sendMoneyToAccount(pin, amount, note, accountNumber, accountName, bankCode);
    _controller.sink.add(result);
  }

  void sendMoneyToPayvice(
      String pin,
      String amount,
      String note,
      String phoneNumber,
      String name
      ) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.sendMoneyToPayvice(pin, amount, note, phoneNumber, name);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<SuccessResponse> response) {
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