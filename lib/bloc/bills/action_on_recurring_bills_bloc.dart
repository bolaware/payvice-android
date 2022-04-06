import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class ActionOnRecurringBillsBloc implements Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkClient = Network();
  final cache = Cache();

  Stream<BaseResponse<GenericResponse>> get stream =>
      _controller.stream;

  Future<void> actionOnRecurringBills(String id, String action) async {
    _controller.sink.add(showLoading());
    final result = await _networkClient.actionOnRecurringBills(id, action);
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