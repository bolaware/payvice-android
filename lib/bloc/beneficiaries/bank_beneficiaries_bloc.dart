import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class BankBeneficiariesBloc implements Bloc {
  final _controller = StreamController<BaseResponse<BankBeneficiaryResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<BankBeneficiaryResponse>> get bankBeneficiaryResponseStream =>
      _controller.stream;

  void getBeneficiaries() async {
    getCachedBeneficairies();
    final result = await _networkclient.getBankBeneficiaries();
    _controller.sink.add(result);
  }

  void getCachedBeneficairies() async {
    final cachedData = await cache.getBeneficiaries();

    BaseResponse<BankBeneficiaryResponse> response;

    if(cachedData != null) {
      response = Success(BankBeneficiaryResponse.fromJson(json.decode(cachedData)));
    } else {
      response = Error(GenericResponse());
    }
    _controller.sink.add(response);
  }

  void hasReadData(BaseResponse<BankBeneficiaryResponse> response) {
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