import 'dart:async';
import 'dart:math';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class PayBillsBloc implements Bloc {
  final _controller = StreamController<BaseResponse<SuccessResponse>>();
  final _networkclient = Network();

  Stream<BaseResponse<SuccessResponse>> get stream =>
      _controller.stream;

  void payBills(String billerCode, String itemCode, String pin, String customerId) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.payBills(billerCode, itemCode, pin, customerId);
    _controller.sink.add(result);
  }

  void payAirtimeForOthers(String amount, String pin, String beneficiaryName, int frequencyId) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.payAirtimeForOthers(amount, pin, beneficiaryName, frequencyId);
    _controller.sink.add(result);
  }

  void payAirtime(String amount) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.payAirtimeForMyself(amount);
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