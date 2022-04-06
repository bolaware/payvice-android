import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/bills/bills_product_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class BillsProductBloc implements Bloc {
  final _controller = StreamController<BaseResponse<List<BillsProduct>>>();
  final _networkclient = Network();

  Stream<BaseResponse<List<BillsProduct>>> get stream =>
      _controller.stream;

  void getBillsProduct(String billGroupCode) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.getBillProducts(billGroupCode);
    if(result is Success) {
      _controller.sink.add(Success((result as Success<BillsProductResponse>).getData().products));
    } else {
      _controller.sink.add(Error(GenericResponse(status: "", statusCode: "", message: "An error occurred while fetching banks.")));
    }
  }

  void hasReadData(BaseResponse<List<BillsProduct>> response) {
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