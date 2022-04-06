import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/set_pin_bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/kaypad.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:toast/toast.dart';

class CreatePinScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  final CreatePinArgument argument;

  CreatePinScreen({Key key, this.argument}) : super(key: key);

  @override
  _CreatePinScreenState createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {

  TextEditingController controller = TextEditingController(text: "");
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var setPinBloc = SetPinBloc();
    return BlocProvider<SetPinBloc>(
      bloc: setPinBloc,
      child: Scaffold(
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
        body: OnboardingContainer(
          child: Column(
            children: [
              Image.asset("images/payvice_logo2.png", height: 60,),
              SizedBox(height: 16.0,),
              Text("${widget.argument == null ? 'Create' : 'Confirm'} your secure pin", style: Theme.of(context).textTheme.headline2,),
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                      "Almost there! ${widget.argument == null ? 'create' : 'confirm'} your pin to enable you sign in and perform transactions",
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
                        controller: controller,
                        maskCharacter: "⬤",
                        pinTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        onTextChanged: (String text){
                          if(text.length == 4) {
                            if(widget.argument != null) {
                              if(widget.argument.pinToConfirm != text) {
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    content: Text("The confirmed pin doesn't correlate. Please check and try again"),
                                  ));
                                });
                                return;
                              }
                              setPinBloc.setPin(text);
                            } else {
                              Navigator.pushNamed(
                                  context,
                                  PayviceRouter.create_pin,
                                  arguments: CreatePinArgument(pinToConfirm: text)
                              );
                            }
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
                            clearListener: () {
                              String currentText = controller.text;
                              if(currentText != null && currentText.isNotEmpty) {
                                controller.text = currentText.substring(0, currentText.length - 1);
                              }
                            },
                          )
                      ),
                      _setPinState(setPinBloc)
                    ],
                  ),
                ),
              )
            ],
          ),
        )
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

  void proceedToNextScreen(SetPinBloc setPinBloc, BaseResponse result) {
    Navigator.pushNamed(context, PayviceRouter.welcome_screen);
  }

  Widget _setPinState(SetPinBloc setPinBloc) {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: setPinBloc.setPinStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                GeneralBottomSheet.showSelectorBottomSheet (
                    context,
                    Column(
                        children: [
                          Image.asset("images/pin_set_successful_icon.png", height: 90.0, width: 90.0,),
                          Text(
                            "Pin created successfully!",
                            style: Theme.of(context).textTheme.headline2.copyWith(
                                fontSize: 20.0
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                                "Keep your pin safe and private at all times",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyText1.copyWith(
                                    color: Colors.black
                                )
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          PrimaryButton(text: "Continue", pressListener: () async {
                            final authenticate = await _checkBiometrics();
                            final biometrics = await _getAvailableBiometrics();
                            if (authenticate && biometrics.isNotEmpty) {
                              GeneralBottomSheet.showSelectorBottomSheet (
                                  context,
                                  Column(
                                    children: [
                                      Image.asset("images/fingerprint_register_icon.png", height: 104.0, width: 100.0,),
                                      SizedBox(height: 16.0,),
                                      Text(
                                        "Enable Biometrics",
                                        style: Theme.of(context).textTheme.headline2.copyWith(
                                            fontSize: 20.0
                                        ),
                                      ),
                                      SizedBox(height: 16.0,),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                        child: Text(
                                            "Enable your phone’s facial or fingerorint recognition quick access",
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context).textTheme.bodyText1.copyWith(
                                                color: Colors.black
                                            )
                                        ),
                                      ),
                                      SizedBox(height: 16.0,),
                                      PrimaryButton(text: "Enable Biometrics", pressListener: () async {
                                        Navigator.pop(context);
                                        if(await _authenticateWithBiometrics()){
                                          await setPinBloc.savePin(controller.text);
                                          Toast.show("Biometrics enrolled!", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
                                          proceedToNextScreen(setPinBloc, result);
                                        } else {
                                          proceedToNextScreen(setPinBloc, result);
                                        }
                                      }),
                                      SizedBox(height: 16.0,),
                                      InkWell(
                                        child: Text('I’ll do this later', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                                        onTap: () {
                                          proceedToNextScreen(setPinBloc, result);
                                        },
                                      )
                                    ],
                                  ), () {

                              });
                            } else {
                              proceedToNextScreen(setPinBloc, result);
                            }
                          })
                        ]
                    ),
                        (){

                    });
                setPinBloc.hasReadData(result);
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
}


class CreatePinArgument {
  final String pinToConfirm;

  CreatePinArgument({@required this.pinToConfirm});
}
