import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/resend_timer_bloc.dart';
import 'package:payvice_app/bloc/onboarding/verification_request_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/verification/set_bvn_complete_bloc.dart';
import 'package:payvice_app/data/response/onboarding/resend_otp_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class BvnVerificationCompleteScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  final BvnVerificationCompleteCodeArgument argument;

  BvnVerificationCompleteScreen({@required this.argument});

  @override
  _BvnVerificationCompleteScreenState createState() => _BvnVerificationCompleteScreenState();
}

class _BvnVerificationCompleteScreenState extends State<BvnVerificationCompleteScreen> {

  TextEditingController codeController = TextEditingController(text: "");


  final confirmOtpBloc = SetBvnCompleteBloc();
  final requestOtpBloc = VerificationRequestBloc();
  final resendBloc = ResendTimerBloc();

  @override
  void initState() {
    resendBloc.startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    double width = MediaQuery.of(context).size.width;

    return BlocProvider(
      bloc: resendBloc,
      child: BlocProvider(
        bloc: requestOtpBloc,
        child: BlocProvider(
          bloc: confirmOtpBloc,
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
                  child: Column(
                    children: [
                      Image.asset("images/payvice_logo2.png", height: 60,),
                      SizedBox(height: 16.0,),
                      Text("Verify BVN", style: Theme.of(context).textTheme.headline2,),
                      StreamBuilder<BaseResponse<ResendOtpResponse>>(
                          stream: requestOtpBloc.phoneVerificationStream,
                          builder: (context, snapshot) {
                            final result = snapshot.data;
                            if (result is Success) {
                              widget.loaderWidget.dismiss(context);
                              if (!result.hasReadData) {
                                codeController.clear();
                                widget.argument.otpPrefix =
                                    (result as Success<ResendOtpResponse>)
                                        .getData()
                                        .resendOtp
                                        .otpPrefix;
                                requestOtpBloc.hasReadData(result);
                              }
                            } else if (result is Error) {
                              widget.loaderWidget.dismiss(context);
                              if (!result.hasReadData) {
                                widget.loaderWidget.dismiss(context);
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  behavior: SnackBarBehavior.floating,
                                  content: Text(
                                      (result as Error).getError().message),
                                ));
                                requestOtpBloc.hasReadData(result);
                              }
                            } else if (result is Loading) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                widget.loaderWidget.showLoaderDialog(context);
                              });
                            }

                            return Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                  "Check your email or phone number to get the verification code starting with ${widget.argument.otpPrefix}",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                                      color: Color(0xFF6E88A9)
                                  )
                              ),
                            );
                          }),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PinCodeTextField(
                                pinBoxHeight: width/10,
                                pinBoxWidth: width/10,
                                pinBoxRadius: 10.0,
                                hideCharacter: true,
                                pinBoxBorderWidth: 1,
                                autofocus: true,
                                maxLength:6,
                                wrapAlignment: WrapAlignment.center,
                                maskCharacter: "⬤",
                                pinTextStyle: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                ),
                                controller: codeController,
                                defaultBorderColor: Color(0xFF0084FF),
                                pinBoxColor: Color(0xFFFCFDFF),
                                highlightPinBoxColor: Color(0xFFDCECFF),
                                hasTextBorderColor: Color(0xFF0084FF),
                                onDone: (String pin) {

                                },
                              ),
                              SizedBox(height: 36.0,),
                              PrimaryButton(
                                text : "Continue",
                                pressListener: () {
                                  if (codeController.text.length == 6) {
                                    confirmOtpBloc.confirmOtp(
                                        codeController.text,
                                        widget.argument.otpPrefix,
                                        widget.argument.mobileNumber);
                                  }
                                },
                              ),
                              SizedBox(height: 16.0,),
                              StreamBuilder<int>(
                                  stream: resendBloc.stream,
                                  initialData: 30,
                                  builder: (context, snapshot) {
                                    if(snapshot.data == 0) {
                                      return InkWell(
                                        onTap: (){
                                          resendBloc.startTimer();
                                          requestOtpBloc.requestOtp(
                                              widget.argument.otpPrefix,
                                              widget.argument.mobileNumber
                                          );
                                        },
                                        child: Text(
                                          "Resend Code",
                                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      );
                                    } else {
                                      return Text(
                                        'Resend code in ${snapshot.data.toString()} sec',
                                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                                            fontWeight: FontWeight.bold
                                        ),
                                      );
                                    }
                                    return Visibility(
                                      visible: snapshot.data != 0,
                                      child: Text(
                                          'Try a different option in ${snapshot.data.toString()} sec',
                                          style: TextStyle(fontSize: 16.0, color: Color(0XFF4CC800))),
                                    );
                                  }
                              ),
                              _loadConfirmationState()
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              )
          ),
        ),
      ),
    );
  }


  Widget _loadConfirmationState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: confirmOtpBloc.phoneVerificationStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Success<GenericResponse>).getData().message),
                ));
                Navigator.pushNamedAndRemoveUntil(
                    context, PayviceRouter.home, (Route<dynamic> route) => false
                );
              });
              confirmOtpBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                confirmOtpBloc.hasReadData(result);
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
    codeController.dispose();
    super.dispose();
  }
}


class BvnVerificationCompleteCodeArgument {
  String otpPrefix;
  final String mobileNumber;

  BvnVerificationCompleteCodeArgument(
      {@required this.otpPrefix, @required this.mobileNumber});
}
