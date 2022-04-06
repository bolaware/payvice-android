import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class RequestMoneyBloc implements Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();
  Stream<BaseResponse<GenericResponse>> get stream =>
      _controller.stream;

  void requestMoneyToPayvice(
      String amount,
      String note,
      String phoneNumber,
      ) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.requestMoneyFromPayvice(amount, note, phoneNumber);
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<GenericResponse> response) {
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