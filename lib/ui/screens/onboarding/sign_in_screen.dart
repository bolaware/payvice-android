

import 'dart:ui';

import 'package:country_code_picker/country_code.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/login_bloc.dart';
import 'package:payvice_app/bloc/profile/identifier_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/get_profile_cache_bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/general_button.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/onboarding/create_pin_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/validators.dart';

const verifyAccountAction = "verify-account";

class SignInScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  SignInScreen({Key key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final identifierController = TextEditingController(); //developer@techdev.work
  final passwordController = TextEditingController(); //Finovo321@
  bool isPhoneMode = false;
  CountryCode _countryCode = CountryCode.fromCountryCode("NG");

  final _formKey = GlobalKey<FormState>();

  final loginBloc = LoginBloc();
  final identifierBloc = IdentifierBloc();

  @override
  void initState() {
    //identifierBloc.getIdentifier();
    super.initState();
  }

  @override
  void dispose() {
    identifierController.dispose();
    super.dispose();
  }

  Widget _loginLoad(LoginBloc loginBloc, GetMemoryProfileBloc profileBloc) {
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
                        mobileNumber:
                        "${isPhoneMode ? _countryCode.dialCode : ""}" +
                            "${identifierController.text}"
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

  @override
  Widget build(BuildContext context) {

    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider<LoginBloc>(
      bloc: loginBloc,
      child: BlocProvider(
        bloc: identifierBloc,
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
              )
          ),
          body: OnboardingContainer(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset("images/payvice_logo2.png", height: 60,),
                  SizedBox(height: 16.0,),
                  Text("Welcome back 👋", style: Theme.of(context).textTheme.headline2,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                        "Log in to your Payvice account",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Colors.black
                        )
                    ),
                  ),
                  SizedBox(height: 16.0,),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(20),
                            right: Radius.circular(20)
                        ),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          _buildIdentifierSwitchButton(),
                          SizedBox(
                            height: 16.0,
                          ),
                          buildIdentifierController(),
                          SizedBox(
                            height: 16.0,
                          ),
                          SingleInputFieldWidget(
                            hint: "Password",
                            validator: Validators.isEmptyValid,
                            isPassword: true,
                            controller: passwordController,
                            textInputType: TextInputType.text,
                            countryCodePickerCallback : (CountryCode code) {
                              _countryCode = code;
                            },
                            isLastField: true,
                          ),
                          SizedBox(height: 24.0,),
                          PrimaryButton(
                            text : "Sign In",
                            pressListener: () {
                              if (_formKey.currentState.validate()) {
                                if(isPhoneMode)
                                  loginBloc.loginWithPhoneNumber(
                                      _countryCode.dialCode, identifierController.text, passwordController.text);
                                else
                                  loginBloc.loginWithEmail(
                                      identifierController.text, passwordController.text);
                              }
                            },
                          ),
                          SizedBox(height: 24.0,),
                          InkWell(
                              child: Text('Forgot Password', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                            onTap: (){
                              Navigator.pushNamed(context, PayviceRouter.reset_password);
                            },
                          ),
                          SizedBox(height: 32.0,),
                          // Icon(Icons.fingerprint, size: 48.0, color: Color(0XFF67B6FF)),
                          Expanded(child: SizedBox.shrink()),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.popAndPushNamed(context, PayviceRouter.sign_up);
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'No account? - ',
                                  style: DefaultTextStyle.of(context).style,
                                  children: const <TextSpan>[
                                    TextSpan(text: 'Sign Up', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _loginLoad(loginBloc, profileBloc)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  Row _buildIdentifierSwitchButton() {
    return Row(
                          children: [
                            StreamBuilder<BaseResponse<Identifier>>(
                              stream: identifierBloc.stream,
                              builder: (context, snapshot) {
                                if(snapshot.data is Success) {
                                  isPhoneMode = (snapshot.data as Success<Identifier>).getData().isPhoneMode;
                                } else {
                                  isPhoneMode = false;
                                }
                                return GeneralButton(
                                  child: LeadingText(
                                    textWidget: Text(
                                      "Switch to ${isPhoneMode ? "Email" : "Phone number"} log in",
                                      style: TextStyle(color: Color(0XFF67B6FF), fontWeight: FontWeight.bold),
                                    ),
                                    icon: Icon(Icons.autorenew_outlined,
                                        size: 16.0, color: Color(0XFF67B6FF)
                                    ),
                                  ),
                                  backgroundColor: Color(0X4067B6FF),
                                  shadowColour: Colors.transparent,
                                  clickListener: () {
                                    FocusManager.instance.primaryFocus.unfocus();
                                    identifierBloc.setTempPhoneMode(!isPhoneMode);
                                  },
                                );
                              }
                            ),
                          ],
                        );
  }

  StreamBuilder<BaseResponse<Identifier>> buildIdentifierController() {
    return StreamBuilder<BaseResponse<Identifier>>(
                            stream: identifierBloc.stream,
                            builder: (context, snapshot) {

                              if(snapshot.data is Success) {
                                isPhoneMode = (snapshot.data as Success<Identifier>).getData().isPhoneMode ?? false;
                                WidgetsBinding.instance.addPostFrameCallback((_) {

                                  identifierController.text = (snapshot.data as Success<Identifier>).getData().identifier;
                                });
                              } else {
                                isPhoneMode = false;
                              }

                              String hint = isPhoneMode ? "Phone Number" : "Email Address";

                              return isPhoneMode ? SingleInputFieldWidget(
                                  hint: hint,
                                  validator: (String phone) {
                                    return Validators.isPhoneValid(phone, _countryCode.dialCode);
                                  },
                                  controller: identifierController,
                                  isPhoneNumberField: true,
                                  textInputType: TextInputType.phone,
                                  countryCodePickerCallback: (CountryCode code) {
                                    _countryCode = code;
                                  }
                              ) : SingleInputFieldWidget(
                                hint: hint,
                                controller: identifierController,
                                validator: Validators.isEmailValid,
                                textInputType: TextInputType.emailAddress,
                              );
                            }
                        );
  }
}
