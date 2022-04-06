import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class BillsCategoryBloc implements Bloc {
  final _controller = StreamController<BaseResponse<BillsCategoryResponse>>();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<BillsCategoryResponse>> get stream =>
      _controller.stream;

  void getBillsCategories() async {
    getCachedBills();
    final result = await _networkclient.getBillCategories();
    _controller.sink.add(result);
  }

  void getCachedBills() async {
    final cachedData = await cache.getBillCategories();

    BaseResponse<BillsCategoryResponse> response;

    if(cachedData != null) {
      response = Success(BillsCategoryResponse.fromJson(json.decode(cachedData)));
      _controller.sink.add(response);
    } else {
      _controller.sink.add(showLoading());
    }
  }

  void hasReadData(BaseResponse<BillsCategoryResponse> response) {
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