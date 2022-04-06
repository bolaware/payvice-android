

import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/reset_password_confirm_bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/validators.dart';

class ResetPasswordCompleteCompleteScreen extends StatefulWidget {

  final ResetPasswordCompleteCompleteScreenArguments arguments;

  final loaderWidget = LoaderWidget();

  ResetPasswordCompleteCompleteScreen({Key key, this.arguments}) : super(key: key);

  @override
  _ResetPasswordCompleteCompleteScreenState createState() => _ResetPasswordCompleteCompleteScreenState();
}

class _ResetPasswordCompleteCompleteScreenState extends State<ResetPasswordCompleteCompleteScreen> {

  final _formKey = GlobalKey<FormState>();

  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final bloc = ResetPasswordConfirmBloc();
    return BlocProvider<ResetPasswordConfirmBloc>(
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
                Text("Password Reset", style: Theme.of(context).textTheme.headline2,),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                      "Kindly input your new password below",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Color(0xFF6E88A9)
                      )
                  ),
                ),
                SizedBox(
                    height: 48.0),
                SingleInputFieldWidget(
                  hint: "New Password",
                  validator: (String password) {
                    return Validators.isPasswordValidCheck(password).getErrorMessage();
                  },
                  isPassword: true,
                  controller: passwordController,
                  textInputType: TextInputType.text,
                ),
                SizedBox(
                    height: 24.0),
                SingleInputFieldWidget(
                  hint: "Confirm Password",
                  validator: (String password) {
                    return Validators.isPasswordValidCheck(password).getErrorMessage();
                  },
                  isPassword: true,
                  controller: confirmPasswordController,
                  textInputType: TextInputType.text,
                  isLastField: true,
                ),
                SizedBox(
                    height: 24.0),
                PrimaryButton(
                  text : "Reset Password",
                  pressListener: () {
                    if (_formKey.currentState.validate()) {
                      if(passwordController.text == confirmPasswordController.text){
                        bloc.requestPasswordRequest(
                            widget.arguments.phoneNumber,
                            widget.arguments.otpPrefix,
                            widget.arguments.otp,
                            passwordController.text
                        );
                      } else {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            behavior: SnackBarBehavior.floating,
                            content: Text("Confirm password doesnt match, please check and try again"),
                          ));
                        });
                      }
                    }
                  },
                ),
                _state(bloc)
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _state(ResetPasswordConfirmBloc bloc) {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: bloc.requestPassStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text((result as Success).getData().message),
                  behavior: SnackBarBehavior.floating)
                );
                Navigator.pushNamedAndRemoveUntil(context, PayviceRouter.sign_in,
                        (Route<dynamic> route) => false);
                confirmPasswordController.clear();
                passwordController.clear();
              });
              bloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                bloc.hasReadData(result);
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
    confirmPasswordController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}


class ResetPasswordCompleteCompleteScreenArguments {
  final String phoneNumber;
  final String otpPrefix;
  final String otp;

  ResetPasswordCompleteCompleteScreenArguments({
    this.phoneNumber, this.otp, this.otpPrefix
  });
}
