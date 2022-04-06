import 'dart:async';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class ResendTimerBloc implements Bloc {

  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;

  Timer _timer;
  int _start;

  void startTimer() {
    _start = 30;
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec, (Timer timer) {
        _controller.sink.add(_start);
        if (_start == 0) {
          timer.cancel();
        } else {
          _start--;
        }
      },
    );
  }

  @override
  Loading<T> showLoading<T>() {
    return Loading();
  }

  @override
  void dispose() {
    print("DISPOSED");
    _timer.cancel();
    _controller.close();
  }

}