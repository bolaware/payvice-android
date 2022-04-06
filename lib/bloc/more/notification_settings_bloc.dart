import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class NotificationSettingsBloc implements Bloc {
  final _controller = StreamController<BaseResponse<LoginResponse>>();
  final _networkClient = Network();
  final cache = Cache();

  Stream<BaseResponse<LoginResponse>> get stream =>
      _controller.stream;

  Future<void> actionOnPreference(String preference, bool value) async {
    _controller.sink.add(showLoading());
    final result = await _networkClient.actionOnPreferences(preference, value.toString());
    _controller.sink.add(result);
  }

  void hasReadData(BaseResponse<LoginResponse> response) {
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