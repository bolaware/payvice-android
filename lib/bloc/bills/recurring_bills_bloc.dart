import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class RecurringBillsBloc implements Bloc {
  final _controller = StreamController<BaseResponse<RecurringBillsResponse>>();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<RecurringBillsResponse>> get stream =>
      _controller.stream;

  BaseResponse<RecurringBillsResponse> _response;

  Future<void> getRecurringBills() async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.getRecurringBills();
    _response = result;
    _controller.sink.add(result);
  }

  void searchContacts(String value) async {
    if (_response is Success) {
      final list = (_response as Success<RecurringBillsResponse>).getData().data.where(
              (element) => element.getSearchableValue().contains(value.toLowerCase())
      ).toList();
      _controller.sink.add(Success(RecurringBillsResponse(data : list)));
    }
  }

  void hasReadData(BaseResponse<RecurringBillsResponse> response) {
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