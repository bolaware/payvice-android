import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/login_bloc.dart';
import 'package:payvice_app/bloc/onboarding/set_pin_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/identifier_bloc.dart';
import 'package:payvice_app/bloc/profile/is_biometric_enrolled_bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/kaypad.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

const verifyAccountAction = "verify-account";

class PinLoginScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  final Identifier identifier;

  PinLoginScreen({Key key, this.identifier}) : super(key: key);

  @override
  _PinLoginScreenState createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {

  TextEditingController controller = TextEditingController(text: "");
  final LocalAuthentication auth = LocalAuthentication();
  final loginBloc = LoginBloc();
  final isBiometricEnabledBloc = IsBiometricEnrolledBloc();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    isBiometricEnabledBloc.isBiometricEnabled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: loginBloc,
      child: BlocProvider(
        bloc: isBiometricEnabledBloc,
        child: Scaffold(
            body: SafeArea(
              child: StreamBuilder<bool>(
                initialData: false,
                stream: isBiometricEnabledBloc.stream,
                builder: (context, snapshot) {
                  final isBiometricEnabled = snapshot.data ?? false;
                  if(isBiometricEnabled) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      authenticate();
                    });
                  }
                  return FormContainer(
                    child: Column(
                      children: [
                        SvgPicture.asset("images/person_login_one_side_rounded_background.svg"),
                        SizedBox(height: 16.0,),
                        Text("Welcome back\n${widget.identifier.firstName}👋", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline2,),
                        SizedBox(height: 16.0,),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(20),
                                  right: Radius.circular(20)
                              ),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                PinCodeTextField(
                                  pinBoxHeight: 50.0,
                                  pinBoxWidth: 50.0,
                                  pinBoxRadius: 10.0,
                                  hideCharacter: true,
                                  pinBoxBorderWidth: 1,
                                  autofocus: false,
                                  hideDefaultKeyboard: true,
                                  maxLength: 4,
                                  controller: controller,
                                  maskCharacter: "⬤",
                                  pinTextStyle: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  onTextChanged: (String text){
                                    if(text.length == 4) {
                                      loginBloc.loginWithPin(widget.identifier.identifier, text);
                                    }
                                  },
                                  defaultBorderColor: Color(0xFF0084FF),
                                  pinBoxColor: Color(0xFFFCFDFF),
                                  highlightPinBoxColor: Color(0xFFDCECFF),
                                  hasTextBorderColor: Color(0xFF0084FF),
                                  onDone: (String pin) {
                                    Navigator.pushNamed(context, PayviceRouter.welcome_screen);
                                  },
                                ),
                                SizedBox(height: 36.0,),
                                Expanded(
                                    child: Keypad(
                                      listener: (String newText){
                                        if(controller.text.length != 4) {
                                          controller.text = controller.text + newText;
                                        }
                                      },
                                      iconData: isBiometricEnabled ? Icons.fingerprint : null,
                                      extraListener: () {
                                        authenticate();
                                      },
                                      clearListener: () {
                                        String currentText = controller.text;
                                        if(currentText != null && currentText.isNotEmpty) {
                                          controller.text = currentText.substring(0, currentText.length - 1);
                                        }
                                      },
                                    )
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.popAndPushNamed(context, PayviceRouter.sign_in);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'This isnt you? ',
                                        style: DefaultTextStyle.of(context).style,
                                        children: const <TextSpan>[
                                          TextSpan(text: 'Sign out', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                _loginLoad(profileBloc)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
              ),
            )
        ),
      ),
    );
  }

  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  bool _isAuthenticating = false;
  String _authorized = 'Not Authorized';

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
          'Scan your fingerprint to authenticate',
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

  void _cancelAuthentication() async {
    await auth.stopAuthentication();
    // setState(() => _isAuthenticating = false);
  }

  void authenticate() async {
    if(await _authenticateWithBiometrics()){
      loginBloc.loginWithBiometric(widget.identifier.identifier);
    }
  }

  void proceedToNextScreen(BaseResponse result) {
    Navigator.pushNamed(context, PayviceRouter.welcome_screen);
  }

  Widget _loginLoad(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: loginBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            profileBloc.setProfile(snapshot.data);
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamedAndRemoveUntil(
                    context, PayviceRouter.home, (Route<dynamic> route) => false
                );
              });
              loginBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if((result as Error).getError().action == verifyAccountAction) {
                  Navigator.pushNamed(
                      context,
                      PayviceRouter.verification_code,
                      arguments: VerificationCodeArgument(
                          otpPrefix: (result as Error).getError().prefix,
                          mobileNumber: widget.identifier.identifier
                      )
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    content: Text((result as Error).getError().message),
                  ));
                }
                loginBloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          } else {}
          return SizedBox.shrink();
        }
    );
  }
}
