import 'dart:async';
import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/response/notification/requests_response.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class RequestListBloc implements Bloc {
  final _controller = StreamController<BaseResponse<List<Request>>>();
  final _networkclient = Network();

  Stream<BaseResponse<List<Request>>> get stream =>
      _controller.stream;

  DateFormat dateFormat = DateFormat("yyyy-MM-ddTHH:mm:ss.z");
  DateFormat outputDateFormat = DateFormat("MMM dd, yyyy");
  DateFormat outputTimeFormat = DateFormat("hh.mm aa");

  final _cache = Cache();

  List<Request> _requestListHolder;

  void getRequests() async {
    _controller.sink.add(showLoading());
    final result = await _networkclient.getRequests();
    if(result is Success) {
      final cachedData = await _cache.getCustomerData();
      Customer me = LoginResponse.fromJson(json.decode(cachedData)).customer;
      List<Request> requestList = (result as Success<RequestsResponse>).getData().data.reversed.map(
              (e) => Request(
              image: "",
              name: me.id == e.customerId ? e.beneficiaryName : e.senderName,
              date: outputDateFormat.format(dateFormat.parseUTC(e.dateRequested).toLocal()),
              time: outputTimeFormat.format(dateFormat.parseUTC(e.dateRequested).toLocal()),
              requestStatus: _getNotificationRequestStatus(e),
              isSentFromMe: me.id == e.customerId,
                amount: e.amount,
                currency: e.currency,
                id: e.id
          )
      ).toList();
      _controller.sink.add(Success(requestList));
      _requestListHolder = requestList.where((element) => true).toList();
    } else {
      _controller.sink.add(Error(GenericResponse(status: "", statusCode: "", message: "An error occurred while fetching banks.")));
    }
  }

  void requestChanged(bool isAcceptAction, int _requestId) {
    final request = _requestListHolder.firstWhere((element) => element.id == _requestId);
    request.requestStatus = isAcceptAction ? RequestStatus.accepted : RequestStatus.declined;
    _controller.sink.add(Success(_requestListHolder));
  }

  RequestStatus _getNotificationRequestStatus(RequestsData request) {
    if (request.answerName.ifNullMakeApprovedTemporary().toLowerCase().contains("accept") || request.answerName.toLowerCase().contains("approve")) {
      return RequestStatus.accepted;
    } else if (request.answerName.ifNullMakeApprovedTemporary().toLowerCase().contains("decline") || request.answerName.toLowerCase().contains("denied") || request.answerName.toLowerCase().contains("reject")) {
      return RequestStatus.declined;
    } else if (request.answerName.ifNullMakeApprovedTemporary().toLowerCase().contains("pend")) {
      return RequestStatus.pending;
    }
  }

  void hasReadData(BaseResponse<List<Request>> response) {
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

extension NullDefault on String {
  String ifNullMakeApprovedTemporary() {
    return this == null ? "accept" : this;
  }
}

class Request {
  String image, name, date, time, currency;
  bool isSentFromMe;
  int id;
  double amount;
  RequestStatus requestStatus;

  String getFomrattedAmount() {
    var formatter = NumberFormat('###,###,###,##0.00');
    return formatter.format(this.amount);
  }

  bool canPerformAction() {
    return !isSentFromMe && requestStatus == RequestStatus.pending;
  }

  String getTitle() {
    String reqeusterName, reqeusteeName;

    if (isSentFromMe) {
      reqeusterName = "You";
      reqeusteeName = name;
    } else {
      reqeusterName = name;
      reqeusteeName = "You";
    }

    if(requestStatus == RequestStatus.pending) {
      return "<b>$reqeusterName</b> requested <span style='color:#0084FF'><b>N${getFomrattedAmount()}</b></span> from <b>$reqeusteeName</b>";
    } else {
      return "<b>$reqeusteeName</b> ${requestStatus == RequestStatus.accepted ? 'accepted' : 'declined'} a request of <span style='color:#0084FF'><b>N${getFomrattedAmount()}</b></span> from <b>$reqeusterName</b>";
    }
  }

  Request({this.image, this.name, this.date, this.time, this.isSentFromMe, this.requestStatus, this.amount, this.currency, this.id});
}

enum RequestStatus {
  pending,
  accepted,
  declined
}