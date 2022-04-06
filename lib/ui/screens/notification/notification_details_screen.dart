import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/notifications/request_list_bloc.dart';
import 'package:payvice_app/bloc/notifications/treat_request_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/notification/treat_request_body.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/validators.dart';

class NotificationDetailsScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  final Request data;

  NotificationDetailsScreen({Key key, this.data}) : super(key: key);

  @override
  _NotificationDetailsScreenState createState() => _NotificationDetailsScreenState();
}

class _NotificationDetailsScreenState extends State<NotificationDetailsScreen> {
  final reasonController = TextEditingController();

  final treatRequestBloc = TreatRequestBloc();

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: treatRequestBloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              "Requests",
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
        body: OnboardingContainer(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset("images/request_illustration.svg"),
                SizedBox(height: 16.0,),
                Text(widget.data.name, style: Theme.of(context).textTheme.titleLarge.copyWith(color: Colors.black)),
                SizedBox(height: 22.0,),
                _buildSendBeneficiaryDetails("N${widget.data.getFomrattedAmount()}"),
                SizedBox(height: 34.0,),
                SingleInputFieldWidget(
                  hint: "Reason",
                  maxLines: 2,
                  validator: Validators.isNameValid,
                  textInputType: TextInputType.text,
                  controller: reasonController,
                ),
                SizedBox(height: 25.0,),
                _getBalance(profileBloc),
                Expanded(child: SizedBox.shrink(),),
                PrimaryButton(text: "Accept", pressListener: () {
                  _treatRequest(widget.data, true);
                }),
                SizedBox(height: 26.0,),
                InkWell(
                  onTap: () {
                    _treatRequest(widget.data, false);
                  }, child: Text("Decline", style: Theme.of(context).textTheme.titleSmall.copyWith(color: Theme.of(context).primaryColor))
                ),
                SizedBox(height: 26.0,),
                _buildTreatRequestResponse()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getBalance(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileBloc.stream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            final Success<LoginResponse> loginResponse = snapshot.data;
            return Center(
              child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.greenAccent.withAlpha(100)),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Payvice Balance: ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(color: Colors.black54),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'N ${loginResponse.getData().balances[0].getFomrattedBalance()}',
                            style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
            );
          }
          return SizedBox.shrink();
        }
    );
  }


  Widget _buildSendBeneficiaryDetails(String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(48),
          dashPattern: const <double>[4, 7],
          color: Theme.of(context).primaryColor,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            decoration: BoxDecoration(
                color: Color(0XAACEE6FF),
                borderRadius: BorderRadius.all(Radius.circular(48))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundColor: Colors.white,
                  child: Icon(PayviceIcons.send, color: Theme.of(context).accentColor,),
                ),
                SizedBox(width: 16.0,),
                Text(amount, style: Theme.of(context).textTheme.titleLarge.copyWith(color: Theme.of(context).primaryColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _treatRequest(Request request, bool accept) async {
    final pin = await Navigator.pushNamed(
        context, PayviceRouter.enter_pin_screen
    );
    if(pin == null) { return; }

    String answer;

    if (accept) {
      answer = "Approved";
    } else {
      answer = "Reject";
    }

    treatRequestBloc.treatRequest(TreatRequestBody(
        answer: answer,
        requestId: request.id,
        transactionPin: pin,
        acceptedAmount: request.amount.toString(),
        message: reasonController.text
    ));
  }

  Widget _buildTreatRequestResponse() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: treatRequestBloc.stream,
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
                Navigator.pop(context, true);
                treatRequestBloc.hasReadData(result);
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
                treatRequestBloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          }
          return SizedBox.shrink();
        }
    );
  }
}
