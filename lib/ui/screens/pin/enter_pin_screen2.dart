import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/is_biometric_enrolled_bloc.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/kaypad.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class EnterPin2Screen extends StatefulWidget {

  final EnterPinScreenType isForSettingFingerPrint;

  const EnterPin2Screen({Key key, this.isForSettingFingerPrint}) : super(key: key);

  @override
  _EnterPin2ScreenState createState() => _EnterPin2ScreenState();
}

class _EnterPin2ScreenState extends State<EnterPin2Screen> {

  TextEditingController controller = TextEditingController(text: "");
  final LocalAuthentication auth = LocalAuthentication();
  final isBiometricEnabledBloc = IsBiometricEnrolledBloc();

  @override
  void initState() {
    if(widget.isForSettingFingerPrint == EnterPinScreenType.validate_transaction) {
      isBiometricEnabledBloc.isBiometricEnabled();
    }
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.grey.shade200,
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
          ),
        ),
        body: BlocProvider(
          bloc: isBiometricEnabledBloc,
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
                return OnboardingContainer(
                  child: Column(
                    children: [

                      SizedBox(height: 16.0,),
                      Text(_getTitle(), style: Theme.of(context).textTheme.headline2,),
                      Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                              _getDescription(),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyText1.copyWith(
                                  color: Color(0xFF6E88A9)
                              )
                          )
                      ),
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
                                maskCharacter: "⬤",
                                pinTextStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                                onTextChanged: (String text){
                                  if(text.length == 4) {
                                    Navigator.pop(
                                        context, controller.text
                                    );
                                    //showTransactionDone();
                                  }
                                },
                                controller: controller,
                                defaultBorderColor: Color(0xFF0084FF),
                                pinBoxColor: Color(0xFFFCFDFF),
                                highlightPinBoxColor: Color(0xFFDCECFF),
                                hasTextBorderColor: Color(0xFF0084FF),
                              ),
                              SizedBox(height: 36.0,),
                              Expanded(
                                  child: Keypad(
                                    listener: (String newText){
                                      if(controller.text.length != 4) {
                                        controller.text = controller.text + newText;
                                      }
                                    },
                                    clearListener: () {
                                      String currentText = controller.text;
                                      if(currentText != null && currentText.isNotEmpty) {
                                        controller.text = currentText.substring(0, currentText.length - 1);
                                      }
                                    },
                                  )
                              ),
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
    );
  }

  String _getTitle() {
    String descWidget;

    switch (widget.isForSettingFingerPrint) {
      case EnterPinScreenType.validate_transaction:
        descWidget = "Enter your PIN";
        break;
      case EnterPinScreenType.generic:
        descWidget = "Enter your PIN";
        break;
      case EnterPinScreenType.set_fingerprint:
        descWidget =  "Enter your PIN";
        break;
      case EnterPinScreenType.first_change_pin:
        descWidget = "Enter your PIN";
        break;
      case EnterPinScreenType.second_change_pin:
        descWidget = "Enter new PIN";
        break;
    }

    return descWidget;
  }

  String _getDescription() {
    String descWidget;

    switch (widget.isForSettingFingerPrint) {
      case EnterPinScreenType.validate_transaction:
        descWidget = "Enter your pin to validate this transaction";
        break;
      case EnterPinScreenType.generic:
        descWidget = "Enter your pin to validate";
        break;
      case EnterPinScreenType.set_fingerprint:
        descWidget = 'Enter your 4-digit PIN to enable fingerprint.';
        break;
      case EnterPinScreenType.first_change_pin:
        descWidget = 'Enter your old 4-digit PIN';
        break;
      case EnterPinScreenType.second_change_pin:
        descWidget = 'Enter your new 4-digit PIN';
        break;
    }

    return descWidget;
  }

  void authenticate() async {
    if(await _authenticateWithBiometrics()){
      controller.text = await Cache().getPass();
      Future.delayed(Duration(seconds: 2), () async {
        goBack();
      });
    }
  }

  void goBack() {
    Navigator.pop(
        context, controller.text
    );
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

enum EnterPinScreenType {
  validate_transaction,
  set_fingerprint,
  first_change_pin,
  second_change_pin,
  generic
}



