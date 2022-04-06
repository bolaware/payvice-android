import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/update_profile_bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/selector_edittext_widget.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/validators.dart';

class SignUpCompleteScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  SignUpCompleteScreen({Key key}) : super(key: key);

  @override
  _SignUpCompleteScreenState createState() => _SignUpCompleteScreenState();
}

class _SignUpCompleteScreenState extends State<SignUpCompleteScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final referralCodeController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  DateTime initialDate;

  @override
  void initState() {
    super.initState();
    initialDate = selectedDate;
  }

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    referralCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateProfileBloc = UpdateProfileBloc();
    return BlocProvider<UpdateProfileBloc>(
      bloc: updateProfileBloc,
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
            )),
        body: OnboardingContainer(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(
                  "images/payvice_logo2.png",
                  height: 60,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Text(
                  "Let’s get to know you more 🎉",
                  style: Theme.of(context).textTheme.headline2,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 36.0, horizontal: 16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(20), right: Radius.circular(20)),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SingleInputFieldWidget(
                          hint: "Full Name",
                          validator: Validators.isNameValid,
                          textInputType: TextInputType.text,
                          controller: fullNameController,
                        ),

                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info,
                                color: Theme.of(context).primaryColor,
                              ),
                              SizedBox(
                                width: 4.0,
                              ),
                              Text("Kindly use legal official name", style: TextStyle(color: Colors.grey),),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.0),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: SelectorEditTextWidget(
                            currentText: initialDate == selectedDate ? "Date of Birth" : "${selectedDate.toLocal()}".split(' ')[0],
                            textColor: initialDate == selectedDate ? Colors.grey.shade700 : Colors.black
                          ),
                        ),
                        SizedBox(height: 16.0,),
                        SingleInputFieldWidget(
                          hint: "Payvice username",
                          validator: Validators.isEmptyValid,
                          textInputType: TextInputType.text,
                          controller: usernameController,
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        SingleInputFieldWidget(
                          hint: "Referral code (optional)",
                          textInputType: TextInputType.text,
                          validator: null,
                          controller: referralCodeController,
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Expanded(child: SizedBox.shrink(),),
                        PrimaryButton(
                          text: "Continue",
                          pressListener: () {
                            if(_formKey.currentState.validate() && selectedDate != initialDate){
                              // Navigator.pushNamed(context, PayviceRouter.create_pin);
                              updateProfileBloc.updateProfile(
                                  fullNameController.text,
                                  "${selectedDate.toLocal()}".split(' ')[0],
                                  usernameController.text,
                                  referralCodeController.text
                              );
                            }
                          },
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Text(
                          "I'll do this later",
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: RichText(
                            text: TextSpan(
                              text: 'By clicking continue, you agree to our - ',
                              style: DefaultTextStyle.of(context).style,
                              children: const <TextSpan>[
                                TextSpan(
                                    text: 'Terms, Conditions',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF67B6FF))),
                                TextSpan(text: ' & '),
                                TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0XFF67B6FF))),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        _updateProfileState(updateProfileBloc)
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ),
    );
  }


  Widget _updateProfileState(UpdateProfileBloc bloc) {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushNamed(context, PayviceRouter.create_pin);
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

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(),
          child: child,
        );
      },
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }


  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                if (picked != null && picked != selectedDate)
                  setState(() {
                    selectedDate = picked;
                  });
              },
              initialDateTime: selectedDate,
              minimumYear: 1930,
              maximumYear: 2030,
            ),
          );
        });
  }
}
