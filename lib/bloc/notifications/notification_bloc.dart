import 'dart:async';

import 'package:intl/intl.dart';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/notification/notification_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/network.dart';

class NotificationBloc implements Bloc {
  final _controller = StreamController<BaseResponse<List<Notificationz>>>();
  final _networkclient = Network();

  Stream<BaseResponse<List<Notificationz>>> get stream =>
      _controller.stream;

  DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.z");
  DateFormat outputDateFormat = DateFormat("MMM dd, yyyy");
  DateFormat outputTimeFormat = DateFormat("hh.mm aa");

  void getNotification() async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.getNotification();
    if(result is Success) {
      List<Notificationz> notiflist = (result as Success<NotificationResponse>).getData().data.map(
              (e) => Notificationz(
                image: "",
                title: e.pushMessage,
                date: outputDateFormat.format(dateFormat.parseUTC(e.dateCreated).toLocal()),
                time: outputTimeFormat.format(dateFormat.parseUTC(e.dateCreated).toLocal()),
                notificationType: e.pushMessage == "Request Money" ? NotificationType.pendingRequest : NotificationType.others
              )
      ).toList();
      _controller.sink.add(Success(notiflist));
    } else {
      _controller.sink.add(Error(GenericResponse(status: "", statusCode: "", message: "An error occurred while fetching banks.")));
    }
  }

  void hasReadData(BaseResponse<List<Notificationz>> response) {
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

class Notificationz {
  String image, title, date, time;
  NotificationType notificationType;
  Notificationz({this.image, this.title, this.date, this.time, this.notificationType});
}

enum NotificationType {
  pendingRequest,
  others
}