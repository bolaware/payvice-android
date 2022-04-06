

import 'dart:convert';

import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/get_remote_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/quick_actions_widget.dart';
import 'package:payvice_app/ui/screens/friends/friends_screen.dart';
import 'package:payvice_app/ui/screens/general_container_screen.dart';
import 'package:payvice_app/ui/screens/home/home_screen.dart';
import 'package:payvice_app/ui/payment_screen.dart';
import 'package:payvice_app/ui/screens/more/more_screen.dart';
import 'package:payvice_app/ui/screens/payment/bills_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';

class HomeContainerScreen extends StatefulWidget {
  @override
  _HomeContainerScreenState createState() => _HomeContainerScreenState();
}

class _HomeContainerScreenState extends State<HomeContainerScreen> with WidgetsBindingObserver {

  final getRemoteProfileBloc = GetRemoteProfileBloc();

  int _selectedIndex = 0;

  bool loggedOut = false;

  static const defaultWidget = Center(
      child: Text(
        "TO DO",
        style: TextStyle(fontSize: 30),)
  );

  List<Widget> _widgetOptions;

  void _setUpForegroundNotificationListener() async {
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );


    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          showSimpleNotification(
            Text(message.notification?.body, style: TextStyle(color: Colors.white),),
            leading: Icon(
              Icons.mail_outline, size: 48, color: Colors.white,
            ),
            //subtitle: Text(message.notification?.body),
            background: Theme.of(context).primaryColor,
            duration: Duration(seconds: 5),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }

    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');
    //
    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  Future<void> getFirebaseTokenAndSave() async {
    String token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    // Assume user is logged in for this example
    await Cache().saveFirebaseTokenKey(token);
  }

  @override
  void initState() {
    _setUpLogoutListenerBroadcast();
    _setUpForegroundNotificationListener();
    getFirebaseTokenAndSave();
    _widgetOptions = [
      HomeScreen(moreActionListener: () {
        _onItemTapped(2);
      }),
      PaymentScreen(),
      defaultWidget,
      FriendsScreen(),
      MoreScreen()
    ];
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(_onLayoutDone);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final getMemoryProfileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: getRemoteProfileBloc,
      child: Scaffold(
          body: StreamBuilder<BaseResponse<LoginResponse>>(
            stream: getRemoteProfileBloc.stream,
            builder: (context, snapshot) {
              if(snapshot.data is Success) {
                final customer = (snapshot.data as Success<LoginResponse>).getData().customer;
                print("fucking me sideways${customer.avatar}");
                getMemoryProfileBloc.setProfile(snapshot.data);
              }
              return _widgetOptions.elementAt(_selectedIndex);
            }
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 50,
              width: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 2,
                onPressed: () {
                  _onItemTapped(2);
                },
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor
                  ),
                  child: SvgPicture.asset(
                    "images/payvice_tab_icon.svg"
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(PayviceIcons.home),
                  label: 'Home'
              ),
              BottomNavigationBarItem(
                icon: Icon(PayviceIcons.thunder),
                label: 'Payments',
              ),
              BottomNavigationBarItem(
                icon: Icon(PayviceIcons.thunder,),
                label: 'Actions',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Friends',
              ),
              BottomNavigationBarItem(
                icon: Icon(PayviceIcons.settings),
                label: 'More',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey.shade700,
            onTap: _onItemTapped,
          )
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      getRemoteProfileBloc.getProfile();
      if(index == 2) {
        _showActionsBottomSheet(context);
      } else {
        _selectedIndex = index;
      }
    });
  }

  void _setUpLogoutListenerBroadcast() {
    FBroadcast.instance().register("logout", (_, __) async {
      FBroadcast.instance().unregister(context);
      if(!loggedOut) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Session timed out. Please login again"),
        ));
        loggedOut = true;
      }

      final identifier = await Cache().getIdentifier();
      Navigator.pushNamedAndRemoveUntil(
          context,
          PayviceRouter.pin_login_screen,
              (Route<dynamic> route) => false,
          arguments: Identifier.fromJson(jsonDecode(identifier))
      );
    }, context: this);
  }

  void _showActionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: EdgeInsets.only(top: 20.0),
          color: Color.fromRGBO(0, 0, 0, 0.001),
          child: GestureDetector(
            onTap: () {},
            child: Stack(
              children: [
                DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  minChildSize: 0.2,
                  maxChildSize: 0.75,
                  builder: (_, controller) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(25.0),
                          topRight: const Radius.circular(25.0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.remove,
                            color: Colors.grey,
                          ),
                          Text("Quick Actions", style: Theme.of(context).textTheme.headline2, textAlign: TextAlign.start,),
                          Expanded(
                            child: FormContainer(child: _quickActions(context)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                    right: 20,
                    bottom: MediaQuery.of(context).size.height * 0.50,
                    child: Container(
                    margin: const EdgeInsets.all(12.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white
                    ),
                    child: GestureDetector(
                        child: Icon(Icons.close, size: 20.0, color: Colors.black,),
                        onTap:(){
                          Navigator.pop(context);
                        }
                    ),
                )),
              ],
            )
          ),
        );
      },
    );
  }

  Column _quickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionsWidget(
                  text: "Airtime & Data",
                  clickListener: () {
                    Navigator.pushNamed(
                        context, PayviceRouter.airtime_data_screen
                    );
                  },
                  iconWidget: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(PayviceIcons.phone, size: 16.0, color: Theme.of(context).accentColor,),
                      ))),
            ),
            SizedBox(width: 12.0,),
            Expanded(
              child: QuickActionsWidget(
                  text: "QR Code",
                  iconWidget: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(PayviceIcons.qr_code, color: Theme.of(context).accentColor,)),
                  clickListener: () {
                    Navigator.pushNamed(
                        context, PayviceRouter.coming_soon_screen
                    );
                  }
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0,),
        Row(
          children: [
            Expanded(
              child: QuickActionsWidget(
                text: "Request money",
                //iconWidget: SvgPicture.asset("images/tolls.svg"),
                iconWidget: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                    child: Icon(PayviceIcons.download_1, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.payvice_friends, arguments: PayviceFriendsScreenArgument(isRequest: true)
                  );
                },
              ),
            ),
            SizedBox(width: 12.0,),
            Expanded(
              child: QuickActionsWidget(
                text: "Send money",
                iconWidget: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                    child: Icon(PayviceIcons.send, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.send_options_screen
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0,),
        Row(
          children: [
            Expanded(
              child: QuickActionsWidget(
                text: "Fund Payvice",
                //iconWidget: SvgPicture.asset("images/tolls.svg"),
                iconWidget: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                    child: Icon(Icons.add, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(context, PayviceRouter.funding_options_screen);
                },
              ),
            ),
            SizedBox(width: 12.0,),
            Expanded(
              child: QuickActionsWidget(
                text: "Pay Bills",
                iconWidget: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                    child: Icon(PayviceIcons.utility, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.general_container_screen, arguments: GeneralContainerScreenArg(title: "Bills", child: BillScreen())
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  _onLayoutDone(_) {
    getRemoteProfileBloc.getProfile();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getRemoteProfileBloc.getProfile();
    }
  }
}
