import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/more/notification_settings_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';

class NotificationSettingScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  NotificationSettingScreen({Key key}) : super(key: key);

  @override
  _NotificationSettingScreenState createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {

  final notificationSettingsBloc = NotificationSettingsBloc();

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: notificationSettingsBloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              "Notifications",
              style: Theme
                  .of(context)
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
                    color: Theme
                        .of(context)
                        .primaryColorDark,
                    size: 24.0,
                  ),
                ),
                shape: CircleBorder(),
              ),
            )),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: StreamBuilder<BaseResponse<LoginResponse>>(
              stream: profileBloc.stream,
              builder: (context, snapshot) {
                final result = snapshot.data;
                if (result is Success) {
                  final preferences =
                      (snapshot.data as Success<LoginResponse>)
                          .getData()
                          .preferences;

                  bool isReferralNotificationEnabled = true;
                  bool isAppNotificationEnabled = true;

                  try {
                    isReferralNotificationEnabled = (preferences.firstWhere((element) => element.preferenceName == "nt-referral-notification")).value == "true";
                  } catch(e) {  }

                  try {
                    isAppNotificationEnabled = (preferences.firstWhere((element) => element.preferenceName == "nt-in-app-notification")).value == "true";
                  } catch(e) {  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 12.0,),
                      Visibility(visible: false,child: _buildProfileRow(context, "Enable referral notifications", isReferralNotificationEnabled, "nt-referral-notification")),
                      SizedBox(height: 12.0,),
                      _buildProfileRow(context, "Enable in-app notifications", isAppNotificationEnabled, "nt-in-app-notification"),
                      _loadConfirmationState(profileBloc)
                    ],
                  );
                }
                return SizedBox.shrink();
              }
            ),
          ),
        ),
      ),
    );
  }

  Material _buildProfileRow(BuildContext context, String title, bool value, String prefName) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shadowColor: Theme.of(context).primaryColor.withAlpha(50),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9)),)),
              CupertinoSwitch(
                activeColor: Theme.of(context).accentColor,
                value: value,
                onChanged: (bool value) {
                  notificationSettingsBloc.actionOnPreference(prefName, value);
                },
              )
            ],
          )
      ),
    );
  }


  Widget _loadConfirmationState(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: notificationSettingsBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                profileBloc.setProfile(snapshot.data);
              });
              notificationSettingsBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                notificationSettingsBloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          } else {}
          return SizedBox.shrink();
        });
  }
}
