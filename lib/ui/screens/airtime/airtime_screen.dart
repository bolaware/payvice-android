import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bills/pay_bills_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';

class AirtimeScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  AirtimeScreen({Key key}) : super(key: key);

  @override
  _AirtimeScreenState createState() => _AirtimeScreenState();
}

class _AirtimeScreenState extends State<AirtimeScreen> {

  AirtimeDataBeneficiary beneficiary;
  AmountScreenResult amountResult;
  final noteController = TextEditingController();
  final payBillsBloc = PayBillsBloc();

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(
            "Airtime",
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
        child: Column(
          children: [
            SizedBox(height: 24.0,),
            StreamBuilder<BaseResponse<LoginResponse>>(
              stream: profileBloc.stream,
              builder: (context, snapshot) {
                return buildSendMoneyOption(context, "Self", "images/person_circle_background.svg", () {
                    final user = (snapshot.data as Success<LoginResponse>).getData().customer;
                    beneficiary = AirtimeDataBeneficiary(name: "Myself", number: user.mobileNumber, photoUrl: user.avatar);

                    goToAmountScreen(true);
                });
              }
            ),
            SizedBox(height: 12.0,),
            buildSendMoneyOption(context, "Others", "images/multi_person_circle_background.svg", () async {
              Navigator.pushNamed(context, PayviceRouter.airtime_others_screen);
            }),
            _sendSuccessScreen()
          ],
        ),
      ),
    );
  }

  Container buildSendMoneyOption(
      BuildContext context,
      String title,
      String assetName,
      Function clickListener
      ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      child: Material(
        elevation: 4,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          onTap: () {
            clickListener();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: LeadingText(
                    textWidget: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 12.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                    icon: SvgPicture.asset(assetName),
                    isHorizontal: true,
                    spacing: 16.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.arrow_forward_ios_outlined, size: 16.0,),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void goToAmountScreen(bool selfAirtime) async {
    final result = await Navigator.pushNamed(
        context,
        PayviceRouter.send_amount_screen,
        arguments: AmountScreenArgument(
            name: beneficiary.name, isRequest: false, photoUrl: beneficiary.photoUrl
        )
    );

    if(result == null) { return; }

    amountResult = result;

    _showConfirmation(selfAirtime);
  }


  void _showConfirmation(bool selfAirtime) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Text(
                  "Confirm Transaction",
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontSize: 20.0
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'You are about to send ',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(text: 'N${amountResult.formattedAmount}', style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.bold)),
                        TextSpan(text: ' airtime to '),
                        TextSpan(text: beneficiary.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  payBillsBloc.payAirtime(
                      amountResult.amount
                  );

                  Navigator.pop(context);
                })
              ]
          ),
              (){

          });
    });
  }

  Widget _sendSuccessScreen(){
    return StreamBuilder<BaseResponse<SuccessResponse>>(
        stream: payBillsBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showTransactionDone((result as Success<SuccessResponse>).getData());
              });
              payBillsBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text((result as Error).getError().message),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5)
                ));
              });
              payBillsBloc.hasReadData(result);
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

  void showTransactionDone(SuccessResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Image.asset("images/pin_set_successful_icon.png", height: 90.0, width: 90.0,),
                Text(
                  "Successful!",
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontSize: 20.0
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: '${amountResult.formattedAmount} Airtime recharge',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      children: const <TextSpan>[
                        TextSpan(text: ' successful', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(text: "See receipt", pressListener: () {
                        Navigator.pushNamed(
                            context,
                            PayviceRouter.transaction_receipt,
                            arguments: ReceiptArgument(
                                title: "Airtime Recharge",
                                description: beneficiary.name,
                                photoUrl: beneficiary.photoUrl,
                                restOfDetails: [
                                  "Amount|N ${amountResult.formattedAmount}",
                                  "Reference|${response.data.payReference}",
                                  "Mobile Number|${beneficiary.number}",
                                  "Status|${response.data.remarks}",
                                  "Date|${response.data.getFormatteDate()}",
                                ]
                            )
                        );
                      }),
                    ),
                    SizedBox(width: 30.0,),
                    Expanded(
                      child: PrimaryButton(
                          text: "Okay",
                          backgroundColor: Color(0xFFF0F7FF),
                          textColor: Theme.of(context).primaryColor,
                          pressListener: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                PayviceRouter.home,
                                    (Route<dynamic> route) => false
                            );
                          }),
                    ),
                  ],
                ),
              ]
          ),
              (){

          });
    });
  }
}


class AirtimeDataBeneficiary{
  final String name, number, photoUrl;

  AirtimeDataBeneficiary({this.name, this.number, this.photoUrl});
}
