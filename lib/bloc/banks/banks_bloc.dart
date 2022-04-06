import 'dart:async';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/banks_list_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class BanksBloc implements Bloc {
  final _controller = StreamController<BaseResponse<BanksListResponse>>.broadcast();
  final _networkclient = Network();
  final cache = Cache();

  Stream<BaseResponse<BanksListResponse>> get stream =>
      _controller.stream;

  void getBanks() async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.getBanks();
    if(result is Success) {
      //cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
    }
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<BanksListResponse> response) {
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