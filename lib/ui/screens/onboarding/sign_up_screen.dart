import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/password_controller_bloc.dart';
import 'package:payvice_app/bloc/onboarding/signup_bloc.dart';
import 'package:payvice_app/data/response/onboarding/signup_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/validators.dart';

const validateOtpAction = "validate-otp";
const validatedOtpAction = "otp-validated";

class SignUpScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  CountryCode _countryCode = CountryCode.fromCountryCode("NG");

  final _formKey = GlobalKey<FormState>();

  final passwordControllerBloc = PasswordControllerBloc();


  void _updatePasswordChecks(PasswordControllerBloc passwordControllerBloc) {
    passwordControllerBloc.setPassword(passwordController.text);
  }

  @override
  void initState() {
    passwordController.addListener(() {
      _updatePasswordChecks(passwordControllerBloc);
    });
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signupBloc = SignupBloc();
    return BlocProvider<PasswordControllerBloc>(
      bloc: passwordControllerBloc,
      child: BlocProvider<SignupBloc>(
        bloc: signupBloc,
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
                  Text("Create your account", style: Theme.of(context).textTheme.headline2,),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                        "Scan to pay bills, send money and receive money easily",
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SingleInputFieldWidget(
                            hint: "Phone Number",
                            validator: (String phone) {
                              return Validators.isPhoneValid(phone, _countryCode.dialCode);
                            },
                            textInputType: TextInputType.phone,
                            controller: phoneController,
                            isPhoneNumberField: true,
                            countryCodePickerCallback: (CountryCode code) {
                              _countryCode = code;
                            }
                          ),
                          SizedBox(height: 16.0),
                          SingleInputFieldWidget(
                            hint: "Email Address",
                            validator: Validators.isEmailValid,
                            iconData: Icons.email,
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          SingleInputFieldWidget(
                            hint: "Password",
                            validator: (String password) {
                              return Validators.isPasswordValidCheck(password).getErrorMessage();
                            },
                            isPassword: true,
                            controller: passwordController,
                            textInputType: TextInputType.text,
                            isLastField: true,
                          ),
                          SizedBox(height: 24.0,),
                          StreamBuilder<PasswordValidatorCheck>(
                              stream: passwordControllerBloc.stream,
                              builder: (context, snapshot) {
                                final result = snapshot.data ??
                                    PasswordValidatorCheck(
                                      isANumber: false,
                                        isLowerCase: false,
                                        isSpecialChar: false,
                                        isUpperCase: false
                                    );
                                return Column(
                                  children: [
                                    ValidatorTextIndicator(
                                        title: "One uppercase character", isValid: result.isUpperCase
                                    ),
                                    ValidatorTextIndicator(
                                        title: "One lowercase character", isValid: result.isLowerCase
                                    ),
                                    ValidatorTextIndicator(
                                        title: "One number", isValid: result.isANumber
                                    ),
                                    ValidatorTextIndicator(
                                        title: "One special character", isValid: result.isSpecialChar
                                    ),
                                  ],
                                );
                              }
                          ),
                          Expanded(child: SizedBox.shrink(),),
                          PrimaryButton(
                            text : "Continue",
                            pressListener: () {
                              if (_formKey.currentState.validate()) {
                                  signupBloc.signUp(
                                      "${_countryCode.dialCode}${phoneController.text}",
                                      emailController.text,
                                      passwordController.text
                                  );
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              child: RichText(
                                text: TextSpan(
                                  text: 'Got an account? - ',
                                  style: DefaultTextStyle.of(context).style,
                                  children: const <TextSpan>[
                                    TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                                  ],
                                ),
                              ),
                              onTap: () {
                                Navigator.popAndPushNamed(context, PayviceRouter.sign_in);
                              },
                            ),
                          ),
                          _signUpState(signupBloc)
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _signUpState(SignupBloc signUpBloc) {
    return StreamBuilder<BaseResponse<SignupResponse>>(
        stream: signUpBloc.signUpResponseStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final successResponse = (result as Success<SignupResponse>).getData();
                switch(successResponse.signup.action) {
                  case validateOtpAction: {
                    Navigator.pushNamed(
                        context,
                        PayviceRouter.verification_code,
                        arguments: VerificationCodeArgument(
                            otpPrefix: successResponse.signup.otpPrefix,
                            mobileNumber: successResponse.getFormattedPhone()
                        )
                    );
                  }
                  break;

                  case validatedOtpAction: {
                    Navigator.pushNamed(
                        context,
                        PayviceRouter.sign_up_complete
                    );
                  }
                  break;

                  default: {}
                  break;
                }
              });
              signUpBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                signUpBloc.hasReadData(result);
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

class ValidatorTextIndicator extends StatelessWidget {
  ValidatorTextIndicator({
    Key key,
    @required this.title,
    @required this.isValid
  }) : super(key: key);

  bool isValid;
  String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SvgPicture.asset(isValid ? "images/checked_validation.svg" : "images/unchecked_validation.svg"),
          SizedBox(width: 8.0,),
          Text(title),
        ],
      ),
    );
  }
}
