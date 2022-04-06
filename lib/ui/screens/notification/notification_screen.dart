import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/notifications/request_list_bloc.dart';
import 'package:payvice_app/bloc/notifications/treat_request_bloc.dart';
import 'package:payvice_app/data/response/notification/treat_request_body.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';

class NotificationScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  NotificationScreen({Key key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final requestListBloc = RequestListBloc();
  final treatRequestBloc = TreatRequestBloc();

  bool _isAcceptAction;
  int _requestId;

  @override
  void initState() {
    requestListBloc.getRequests();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return BlocProvider(
      bloc: requestListBloc,
      child: BlocProvider(
        bloc: treatRequestBloc,
        child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              title: Text(
                "Notifications",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              leading: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RawMaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  elevation: 2.0,
                  fillColor: Color(0xFFEFF6FE),
                  child: Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).primaryColorDark,
                      size: 24.0,
                    ),
                  ),
                  shape: CircleBorder(),
                ),
              )),
          body: StreamBuilder<BaseResponse<List<Request>>>(
            stream: requestListBloc.stream,
            builder: (context, snapshot) {
              final result = snapshot.data;
              if (result is Success) {
                widget.loaderWidget.dismiss(context);
                var notificationList = (result as Success<List<Request>>).getData();
                if (notificationList.isNotEmpty) {
                  return Container(
                    child: ListView.builder(
                        key: PageStorageKey('request list'),
                        itemCount: notificationList.length,
                        itemBuilder: (context, index) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Slidable(
                               enabled: notificationList[index].canPerformAction(),
                                startActionPane: ActionPane(
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (context) {
                                        _treatRequest(notificationList[index], true);
                                      },
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      icon: Icons.check,
                                      label: 'Accept',
                                    ),
                                  ],
                                ),
                                endActionPane: ActionPane(
                                  // A motion is a widget used to control how the pane animates.
                                  motion: const ScrollMotion(),

                                  // All actions are defined in the children parameter.
                                  children: [
                                    // A SlidableAction can have an icon and/or a label.
                                    SlidableAction(
                                      onPressed: (context) {
                                        _treatRequest(notificationList[index], false);
                                      },
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      icon: Icons.close,
                                      label: 'Decline',
                                    ),
                                  ],
                                ),
                                child: _buildNotificationCard(notificationList[index]),
                              )
                          );
                        }
                    ),
                  );
                } else {
                  return Center(
                    child: Text("No notifications yet")
                  );
                }
              } else if (result is Loading) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  widget.loaderWidget.showLoaderDialog(context);
                });
              } else if(snapshot.data is Error) {
                widget.loaderWidget.dismiss(context);
                if (!result.hasReadData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text((result as Error).getError().message),
                    ));
                    requestListBloc.hasReadData(result);
                  });
                }
              }
              return SizedBox.shrink();
            }
          ),
          bottomSheet: _buildTreatRequestResponse(),
        ),
      ),
    );
  }

  void _treatRequest(Request request, bool accept) async {
    final pin = await Navigator.pushNamed(
        context, PayviceRouter.enter_pin_screen
    );
    if(pin == null) { return; }

    String answer;

    if (accept) {
      answer = "Approved";
      _isAcceptAction = true;
      _requestId = request.id;
    } else {
      answer = "Reject";
      _isAcceptAction = false;
      _requestId = request.id;
    }

    treatRequestBloc.treatRequest(TreatRequestBody(
        answer: answer,
        requestId: request.id,
        transactionPin: pin,
        acceptedAmount: request.amount.toString(),
        message: ""
    ));
  }

  Widget _buildTreatRequestResponse() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: treatRequestBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              requestListBloc.requestChanged(_isAcceptAction, _requestId);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Success<GenericResponse>).getData().message),
                ));
                treatRequestBloc.hasReadData(result);
              });
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                treatRequestBloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          }
          return SizedBox.shrink();
        }
    );
  }

  Widget _buildNotificationCard(Request request) {
    return GestureDetector(
      onTap: () async {
        if (request.canPerformAction()) {
          final result = await Navigator.pushNamed(context, PayviceRouter.request_details_screen, arguments: request);

          if(result != null) { requestListBloc.getRequests(); }
        }
      },
      child: Material(
        elevation: 2,
        color: Colors.white,
        shadowColor: Theme.of(context).primaryColor.withAlpha(50),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(
                      "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"),
                ),
                SizedBox(width: 16.0,),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Html(
                          data: request.getTitle(),
                            style: {'body': Style(margin: EdgeInsets.zero, padding: EdgeInsets.zero)}
                        ),
                        SizedBox(height: 8.0,),
                        Text(
                          "${request.time} • ${request.date}",
                          style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 12.0, color: Colors.black54),
                        )
                      ],
                    )
                ),
              ],
            )
        ),
      ),
    );
  }
}
