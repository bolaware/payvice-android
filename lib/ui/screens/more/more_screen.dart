import 'dart:convert';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/more/change_pin_bloc.dart';
import 'package:payvice_app/bloc/more/set_biometric_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/is_biometric_enrolled_bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/ui/customs/general_button.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/screens/pin/enter_pin_screen2.dart';

class MoreScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  MoreScreen({Key key}) : super(key: key);

  @override
  _MoreScreenState createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {

  final changePinBloc = ChangePinBloc();

  final LocalAuthentication auth = LocalAuthentication();
  final setPinBloc = SetBiometricBloc();
  final isBiometricEnabledBloc = IsBiometricEnrolledBloc();

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: changePinBloc,
      child: BlocProvider(
        bloc: setPinBloc,
        child: BlocProvider(
          bloc: isBiometricEnabledBloc,
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: SizedBox.shrink(),
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              title: Text(
                "More",
                style: Theme.of(context)
                    .textTheme
                    .headline3
                    .copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            body: StreamBuilder<BaseResponse<LoginResponse>>(
              stream: profileBloc.stream,
              builder: (context, snapshot) {

                final result = snapshot.data;
                if (result is Success) {
                  final loginResponse = (snapshot.data as Success<LoginResponse>).getData();
                  return SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "Profile",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          _buildEditProfileContainer(loginResponse),
                          Text(
                            "My Account",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          SizedBox(height: 7.0,),
                          Visibility(visible: false, child: _buildSettingsRow(context, "Banks & Cards", "images/card_icon.svg")),
                          SizedBox(height: 12.0,),
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    PayviceRouter.verification_list_page
                                );
                              },
                              child: _buildSettingsRow(context, "Verification", "images/verify_icon.svg")
                          ),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, PayviceRouter.coming_soon_screen
                                );
                              },
                              child: _buildSettingsRow(context, "Referrals", "images/gift_icon.svg")
                          ),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    PayviceRouter.notification_setting_screen
                                );
                              },
                              child: _buildSettingsRow(context, "Notifications", "images/bell_icon.svg")
                          ),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    PayviceRouter.request_statement_screen
                                );
                              },
                              child: _buildSettingsRow(context, "Request Statement", "images/mail_icon.svg")),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    PayviceRouter.recurring_bills_screen
                                );
                              },
                              child: _buildSettingsRow(context, "Recurring Bills", "images/mail_icon.svg")
                          ),
                          SizedBox(height: 12.0,),
                          Text(
                            "Security",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          SizedBox(height: 7.0,),
                          InkWell(
                              onTap: () {
                                Navigator.pushNamed(
                                    context,
                                    PayviceRouter.change_password_screen
                                );
                              },
                              child: _buildSettingsRow(context, "Change Password", "images/padlock_icon.svg")),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () async {
                                final oldPin = await Navigator.pushNamed(
                                    context, PayviceRouter.enter_pin_screen, arguments: EnterPinScreenType.first_change_pin
                                );

                                if(oldPin == null) { return; }

                                final newPin = await Navigator.pushNamed(
                                    context, PayviceRouter.enter_pin_screen, arguments: EnterPinScreenType.second_change_pin
                                );

                                if(newPin == null) { return; }

                                changePinBloc.changePin(oldPin, newPin);
                              },
                              child: _buildSettingsRow(context, "Change Payvice PIN", "images/pin_icon.svg")
                          ),
                          SizedBox(height: 12.0,),
                          GestureDetector(
                              onTap: () {  },
                              child: _buildFingerprintRow(context, "Fingerprint/Face ID")),
                          SizedBox(height: 12.0,),
                          Text(
                            "Payvice",
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                          SizedBox(height: 7.0,),
                          _buildSettingsRow(context, "About Payvice", "images/copy_icon.svg"),
                          SizedBox(height: 12.0,),
                          _buildSettingsRow(context, "Chat with us", "images/chat_icon.svg"),
                          SizedBox(height: 12.0,),
                          _buildSettingsRow(context, "FAQ & Privacy Policy", "images/copy_icon.svg"),
                          SizedBox(height: 12.0,),
                          Row(
                            children: [
                              Expanded(child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Payvice 1.0.0", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black54),),
                              )),
                              InkWell(
                                onTap: () async{
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      PayviceRouter.pin_login_screen,
                                      (Route<dynamic> route) => false,
                                      arguments: Identifier.fromJson(jsonDecode(await Cache().getIdentifier()))
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("Log out", textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.red),),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 24.0,),
                          _loadChangePinBlocState(),
                          _loadSetPinBlocState()
                        ],
                      ),
                    ),
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

  Widget _loadChangePinBlocState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: changePinBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                isBiometricEnabledBloc.enableBiometrics(false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Success<GenericResponse>).getData().message),
                ));
              });
              changePinBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                changePinBloc.hasReadData(result);
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

  Widget _loadSetPinBlocState() {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: setPinBloc.setPinStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                if(await _authenticateWithBiometrics()){
                  isBiometricEnabledBloc.enableBiometrics(true);
                  await setPinBloc.savePin(setPinBloc.tempPin);
                  showSnackbar("Biometrics enrolled!");
                }
                setPinBloc.hasReadData(result);
              });
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showSnackbar((result as Error).getError().message);
                setPinBloc.hasReadData(result);
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

  Widget _buildEditProfileContainer(LoginResponse loginResponse) {
    final customer = loginResponse.customer;
    return Container(
      padding: EdgeInsets.all(16.0),
      margin:
      const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Colors.greenAccent.withAlpha(20)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                Theme.of(context).primaryColor.withAlpha(30),
                foregroundImage: NetworkImage(customer.getAvatar()),
                child: SvgPicture.asset(
                    "images/multi_coloured_person.svg"),
              ),
              Positioned(
                top: 0.0,
                right: 0.0,
                child: new InkWell(
                    child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor),
                        child: Icon(
                          Icons.check,
                          size: 16.0,
                          color: Colors.white,
                        )),
                    onTap: () {}),
              )
            ],
          ),
          SizedBox(
            width: 12.0,
          ),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "${customer.firstName} ${customer.lastName}",
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        .copyWith(fontSize: 24.0),
                  ),
                  Text(
                    "${customer.mobileNumber}",
                    style: TextStyle(color: Colors.black54),
                  ),
                  SizedBox(
                    height: 12.0,
                  ),
                  Visibility(
                    visible: true,
                    child: Row(
                      children: [
                        GeneralButton(
                          backgroundColor: Theme.of(context).primaryColor,
                          borderRadius: 24.0,
                          clickListener: () {
                            Navigator.pushNamed(
                                context,
                                PayviceRouter.edit_profile_screen
                            );
                          },
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Edit Profile",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                              Padding(
                                  padding:
                                  EdgeInsets.only(top: 2.0, left: 2.0),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    size: 12.0,
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  Material _buildSettingsRow(BuildContext context, String title, String image) {
    return Material(
            elevation: 2,
            color: Colors.white,
            shadowColor: Theme.of(context).primaryColor.withAlpha(50),
            borderRadius: BorderRadius.all(Radius.circular(4)),
            child: Container(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SvgPicture.asset(image),
                    ),
                    Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.black54,),
                    ),
                  ],
                )
            ),
          );
  }

  Material _buildFingerprintRow(BuildContext context, String title) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shadowColor: Theme.of(context).primaryColor.withAlpha(50),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      child: Container(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
              ),
              Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _fingerPrintSwitch((bool switchOn) async {
                  if(switchOn) {
                    final canAuthenticate = await _checkBiometrics();
                    final biometrics = await _getAvailableBiometrics();
                    if(!canAuthenticate || biometrics.isEmpty) {
                      showSnackbar("Please enroll biometrics on your device first!");
                      return;
                    }

                    final pin = await Navigator.pushNamed(
                        context, PayviceRouter.enter_pin_screen, arguments: EnterPinScreenType.set_fingerprint
                    );

                    if(pin == null) { return; }

                    setPinBloc.loginWithPin(pin);
                  } else {
                    Cache().clearBiometric();
                    isBiometricEnabledBloc.enableBiometrics(false);
                  }
                }),
              ),
            ],
          )
      ),
    );
  }

  Widget _fingerPrintSwitch(Function switchFunction) {
    isBiometricEnabledBloc.isBiometricEnabled();
    return StreamBuilder<bool>(
        stream: isBiometricEnabledBloc.stream,
        builder: (context, snapshot) {
          print("fffhfhhfhfhhhf 2 ${snapshot.data}");
          return Transform.scale(
            scale: 0.75,
            child: CupertinoSwitch(
              value: snapshot.data ?? false,
              onChanged: (bool switchOn) {
                switchFunction(switchOn);
              },
            ),
          );
        }
    );
  }

  void showSnackbar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(text),
    ));
  }

  Future<bool> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return false;

    return canCheckBiometrics;
  }

  Future<List<BiometricType>> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) null;

    return availableBiometrics;
  }

  Future<bool> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      // setState(() {
      //   _isAuthenticating = true;
      //   _authorized = 'Authenticating';
      // });
      authenticated = await auth.authenticate(
          localizedReason:
          'Scan your fingerprint/face to authenticate',
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true);
      // setState(() {
      //   _isAuthenticating = false;
      //   _authorized = 'Authenticating';
      // });
    } on PlatformException catch (e) {
      print(e);
      // setState(() {
      //   _isAuthenticating = false;
      //   _authorized = "Error - ${e.message}";
      // });
      return false;
    }
    if (!mounted) return false;

    return authenticated;
  }
}
