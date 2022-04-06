import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/activities/actvities_response.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class ActivitiesBloc implements Bloc {
  final _controller = StreamController<BaseResponse<ActivitiesResponse>>();
  final _networkclient = Network();
  final cache = Cache();
  Stream<BaseResponse<ActivitiesResponse>> get bankBeneficiaryResponseStream =>
      _controller.stream;

  void getActivities() async {
    getCachedActivities();
    final result = await _networkclient.getActivities();
    if(result is Success) {
      //cache.saveToken((result as Success<LoginResponse>).getData().token.accessToken);
    }
    _controller.sink.add(result);
  }

  void getCachedActivities() async {
    final cachedData = await cache.getActivities();

    BaseResponse<ActivitiesResponse> response;

    if(cachedData != null) {
      response = Success(ActivitiesResponse.fromJson(json.decode(cachedData)));
    } else {
      response = Error(GenericResponse());
    }
    _controller.sink.add(response);
  }

  void hasReadData(BaseResponse<ActivitiesResponse> response) {
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