import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/verification/set_bvn_bloc.dart';
import 'package:payvice_app/data/response/onboarding/signup_response.dart';
import 'package:payvice_app/data/response/verification/verification_initial_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/bvn_verification_complete_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/validators.dart';


const validateOtpAction = "validate-bvn";

class BvnVerificationInitialScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  BvnVerificationInitialScreen({Key key}) : super(key: key);

  @override
  _BvnVerificationInitialScreenState createState() => _BvnVerificationInitialScreenState();
}

class _BvnVerificationInitialScreenState extends State<BvnVerificationInitialScreen> {

  final bvnController = TextEditingController();
  final dobController = TextEditingController();
  final setBvnBloc = SetBvnBloc();

  final _formKey = GlobalKey<FormState>();

  DateTime selectedDate = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(
            "BVN",
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
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
      body: Container(
        child: Form(
          key: _formKey,
          child: FormContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      "Please verify your BVN. Your BVN helps us protect your account",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Color(0xFF6E88A9)
                      )
                  ),
                ),
                SizedBox(height: 24.0,),
                SingleInputFieldWidget(
                  hint: "BVN",
                  controller: bvnController,
                  maxLength: 11,
                  validator: Validators.isEmptyValid,
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 14.0,),
                GestureDetector(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Container(
                    color: Colors.transparent,
                    child: IgnorePointer(
                      child: SingleInputFieldWidget(
                        hint: "Date of Birth",
                        controller: dobController,
                        validator: Validators.isEmptyValid,
                        iconData: Icons.calendar_today_outlined,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 48.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  if(_formKey.currentState.validate()) {
                    setBvnBloc.setBvn(bvnController.text, dobController.text);
                  }
                }),
                SizedBox(height: 32.0,),
                _successScreen()
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _successScreen() {
    return StreamBuilder<BaseResponse<BvnVerificationInitialResponse>>(
        stream: setBvnBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final successResponse = (result as Success<BvnVerificationInitialResponse>).getData();
                switch(successResponse.validateBvn.action) {
                  case validateOtpAction: {
                    Navigator.pushNamed(
                        context,
                        PayviceRouter.bvn_verification_complete,
                        arguments: BvnVerificationCompleteCodeArgument(
                            otpPrefix: successResponse.validateBvn.otpPrefix,
                            mobileNumber: successResponse.getFormattedPhone()
                        )
                    );
                  }
                  break;

                  default: {}
                  break;
                }
              });
              setBvnBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                setBvnBloc.hasReadData(result);
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
    selectedDate = picked;
    dobController.text = "${picked.toLocal()}".split(' ')[0];
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
                selectedDate = picked;
                dobController.text = "${picked.toLocal()}".split(' ')[0];
              },
              initialDateTime: selectedDate,
              minimumYear: 1930,
              maximumYear: 2030,
            ),
          );
        });
  }

}
