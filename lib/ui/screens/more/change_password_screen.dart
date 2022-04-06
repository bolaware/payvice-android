import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/more/change_pass_bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/validators.dart';

class ChangePasswordScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  ChangePasswordScreen({Key key}) : super(key: key);

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final _formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();

  final changePassBloc = ChangePassBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: changePassBloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              "Change Password",
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
                  SizedBox(height: 24.0,),
                  SingleInputFieldWidget(
                    hint: "Current Password",
                    controller: oldPasswordController,
                    isPassword: true,
                    validator: Validators.isEmptyValid,
                  ),
                  SizedBox(height: 14.0,),
                  SingleInputFieldWidget(
                    hint: "New Password",
                    controller: newPasswordController,
                    isPassword: true,
                    validator: Validators.isEmptyValid,
                  ),
                  SizedBox(height: 14.0,),
                  SingleInputFieldWidget(
                    hint: "Confirm new password",
                    controller: confirmNewPasswordController,
                    isPassword: true,
                    validator: (String value) {
                      return Validators.similarityValid(
                          value, newPasswordController.text
                      );
                    }
                  ),
                  Expanded(child: SizedBox.shrink()),
                  PrimaryButton(text: "Continue", pressListener: () async {
                    if(_formKey.currentState.validate()) {
                      changePassBloc.changePassword(oldPasswordController.text, confirmNewPasswordController.text);
                    }
                  }),
                  SizedBox(height: 32.0,),
                  _loadChangePinBlocState()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _loadChangePinBlocState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: changePassBloc.stream,
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
                Navigator.pop(context);
              });
              changePassBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                changePassBloc.hasReadData(result);
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
