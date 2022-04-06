import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';

class AccountBankResolveVisibilityBloc implements Bloc {

  final _isVisibleController = StreamController<bool>();
  Stream<bool> get visibilityStream => _isVisibleController.stream;

  void setVisibility(bool isVisible) async {
    _isVisibleController.sink.add(isVisible);
  }

  @override
  Loading<T> showLoading<T>() {
    return Loading();
  }

  @override
  void dispose() {
    print("DISPOSED");
    _isVisibleController.close();
  }
}