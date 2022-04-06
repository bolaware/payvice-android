import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/notification/treat_request_body.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class TreatRequestBloc implements Bloc {
  final _controller = StreamController<BaseResponse<GenericResponse>>();
  final _networkclient = Network();

  Stream<BaseResponse<GenericResponse>> get stream =>
      _controller.stream;

  DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.z");
  DateFormat outputDateFormat = DateFormat("MMM dd, yyyy");
  DateFormat outputTimeFormat = DateFormat("hh.mm aa");

  void treatRequest(TreatRequestBody request) async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.treatRequest(request);
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