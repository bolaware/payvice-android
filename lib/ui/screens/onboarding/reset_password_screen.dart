
import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/reset_password_request_bloc.dart';
import 'package:payvice_app/data/response/onboarding/reset_password_request_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/onboarding/create_pin_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/reset_password_confirmation_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/validators.dart';

class ResetPasswordScreen extends StatefulWidget {
  ResetPasswordScreen({Key key}) : super(key: key);

  final loaderWidget = LoaderWidget();

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final identifierController = TextEditingController();
  CountryCode _countryCode = CountryCode.fromCountryCode("NG");

  @override
  Widget build(BuildContext context) {
    final bloc = ResetPasswordRequestBloc();
    return BlocProvider<ResetPasswordRequestBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
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
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text("Reset your Password", style: Theme.of(context).textTheme.headline2,),
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                        "Enter your phone number below to receive a pin to reset your password",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Color(0xFF6E88A9)
                        )
                    ),
                ),
                SizedBox(height: 48.0),
                SingleInputFieldWidget(
                    hint: "Phone Number",
                    validator: (String phone) {
                      return Validators.isPhoneValid(phone, _countryCode.dialCode);
                    },
                    controller: identifierController,
                    isPhoneNumberField: true,
                    textInputType: TextInputType.phone,
                    countryCodePickerCallback: (CountryCode code) {
                      _countryCode = code;
                    }
                ),
                SizedBox(
                    height: 24.0),
                PrimaryButton(
                  text : "Send reset pin",
                  pressListener: () {
                    if (_formKey.currentState.validate()) {
                      bloc.requestPasswordRequest(
                          "${_countryCode.dialCode}${identifierController.text}"
                      );
                    }
                  },
                ),
                _forgotPasswordState(bloc)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _forgotPasswordState(ResetPasswordRequestBloc loginBloc) {
    return StreamBuilder<BaseResponse<ResetPasswordRequestResponse>>(
        stream: loginBloc.requestPassStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ResetPasswordConfirmationScreen(
                         argument: VerificationCodeArgument(
                           mobileNumber: (result as Success<ResetPasswordRequestResponse>).getData().getFormattedPhone(),
                           otpPrefix: (result as Success<ResetPasswordRequestResponse>).getData().passwordReset.otpPrefix,
                         )
                      )
                  ),
                );
              });
              loginBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                loginBloc.hasReadData(result);
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

  @override
  void dispose() {
    identifierController.dispose();
    super.dispose();
  }
}
