import 'dart:async';
import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bills/pay_bills_bloc.dart';
import 'package:payvice_app/bloc/bills/resolve_mobile_number_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/bills/mobile_number_resolve_response.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/airtime/airtime_screen.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';

class AirtimeOthersScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  AirtimeOthersScreen({Key key}) : super(key: key);

  @override
  _AirtimeOthersScreenState createState() => _AirtimeOthersScreenState();
}

class _AirtimeOthersScreenState extends State<AirtimeOthersScreen> {
  final customerIdController = TextEditingController();
  final frequencyController = TextEditingController();
  var isRecurringBilllChecked = false;
  CountryCode _countryCode = CountryCode.fromCountryCode("NG");
  AirtimeDataBeneficiary beneficiary;
  AmountScreenResult amountResult;
  final payBillsBloc = PayBillsBloc();
  final resolveBloc = ResolveMobileNumberBloc();

  Timer _debounce;

  @override
  void initState() {
    customerIdController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        resolveBloc.resolveAccountNumber(getEnteredMobileNumber());
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    customerIdController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
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
      body: FormContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _getBalance(context, profileBloc),
            SizedBox(height: 24.0,),
            SingleInputFieldWidget(
              hint: "Phone Number",
              controller: customerIdController,
              isPhoneNumberField: true,
              textInputType: TextInputType.phone,
              countryCodePickerCallback : (CountryCode code) {
                _countryCode = code;
              },
              isLastField: true,
            ),
            SizedBox(height: 16.0,),
            InkWell(
              onTap: () async {
                final result = await Navigator.pushNamed(context, PayviceRouter.payvice_friends,
                    arguments: PayviceFriendsScreenArgument(isRequest: false, forSelectionPurpose: true));

                if (result != null) {
                  beneficiary = result;
                  customerIdController.text = (result as AirtimeDataBeneficiary).number;
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person, color: Theme.of(context).primaryColor,),
                  SizedBox(width: 8.0,),
                  Text(
                    "Select contact",
                    style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0,),
            StreamBuilder<BaseResponse<MobileNumberResolveResponse>>(
              stream: resolveBloc.stream,
              builder: (context, snapshot) {
                final result = snapshot.data;
                if (result is Success) {
                  final response = (result as Success<MobileNumberResolveResponse>).getData();
                  return Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        color: Theme.of(context).accentColor.withAlpha(80)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Network",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          response.data.provider,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return SizedBox.shrink();
              }
            ),
            SizedBox(height: 16.0,),
            Row(
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: this.isRecurringBilllChecked,
                    onChanged: (bool value) {
                      setState(() {
                        if(!value) {
                          frequencyController.text = "";
                        } else {
                          //default is monthly
                          frequencyController.text = "Monthly";
                          _showRecurringPaymentOption();
                        }
                        this.isRecurringBilllChecked = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.0,),
                Text(
                  "Set as recurring bill",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                )
              ],
            ),
            SizedBox(height: 8.0,),
            Visibility(
              visible: frequencyController.text.isNotEmpty,
              child: GestureDetector(
                onTap: () {
                  _showRecurringPaymentOption();
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    color: Theme.of(context).accentColor.withAlpha(80)),
                  child: Text(
                    frequencyController.text,
                    style: Theme.of(context)
                        .textTheme
                        .bodyText2
                        .copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Expanded(child: SizedBox.shrink()),
            PrimaryButton(text: "Continue", pressListener: () async {
              if(getEnteredMobileNumber().isNotEmpty) {
                goToAmountScreen();
              }
            }),
            SizedBox(height: 32.0,),
            _sendSuccessScreen()
          ],
        ),
      ),
    );
  }

  void _showRecurringPaymentOption() {
    GeneralBottomSheet.showSelectorBottomSheet (
        context,
        Column(
            children: [
              Text(
                "Set recurring payment",
                style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 20.0),
              ),
              SizedBox(height: 16.0,),
              ClickableContainer(
                tapListener: () { },
                tapDownListener: (TapDownDetails details) {
                  _showPopupMenu(details.globalPosition);
                },
                child: SingleInputFieldWidget(
                  hint: "Frequency",
                  controller: frequencyController,
                  iconData: Icons.keyboard_arrow_down_rounded,
                ),
              ),
              SizedBox(height: 24.0,),
              PrimaryButton(text: "Continue", pressListener: () async {
                // to update frequencyController
                setState(() {  });
                Navigator.pop(context);
              }),
            ]
        ),
            (){

        });
  }

  _showPopupMenu(Offset offset) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(left, top, left + 1, top + 1),
      items: [
        PopupMenuItem<String>(
            child: const Text('Hourly'), value: 'Hourly', onTap: () {
                frequencyController.text = "Hourly";
        }),
        PopupMenuItem<String>(
            child: const Text('Daily'), value: 'Daily', onTap: () {
              frequencyController.text = "Daily";
        }),
        PopupMenuItem<String>(
            child: const Text('Weekly'), value: 'Weekly', onTap: () {
              frequencyController.text = "Weekly";
        }),
        PopupMenuItem<String>(
            child: const Text('Monthly'), value: 'Monthly', onTap: () {
              frequencyController.text = "Monthly";
        }),
        PopupMenuItem<String>(
            child: const Text('Yearly'), value: 'Yearly', onTap: () {
          frequencyController.text = "Yearly";
        }),
      ],
      elevation: 8.0,
    );
  }

  Widget _getBalance(BuildContext context, GetMemoryProfileBloc profileBloc) {
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

  Future<void> goToAmountScreen() async {
    if (beneficiary == null) {
      beneficiary = AirtimeDataBeneficiary(name: getEnteredMobileNumber(), number: getEnteredMobileNumber());
    } else if(beneficiary.number != customerIdController.text) {
      beneficiary = AirtimeDataBeneficiary(name: getEnteredMobileNumber(), number: getEnteredMobileNumber());
    }
    final result = await Navigator.pushNamed(
        context,
        PayviceRouter.send_amount_screen,
        arguments: AmountScreenArgument(
            name: beneficiary.name, isRequest: false, photoUrl: beneficiary.photoUrl
        )
    );

    if(result == null) { return; }

    amountResult = result;

    _showConfirmation();
  }

  void _showConfirmation() {
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
                        TextSpan(text: beneficiary.name ?? getEnteredMobileNumber(), style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  final pin = await Navigator.pushNamed(
                      context, PayviceRouter.enter_pin_screen
                  );

                  if(pin == null) { return; }

                  payBillsBloc.payAirtimeForOthers(
                      amountResult.amount, pin, beneficiary.number, getFrequencyId()
                  );

                  Navigator.pop(context);
                })
              ]
          ),
              (){

          });
    });
  }

  int getFrequencyId(){
    switch(frequencyController.text.toLowerCase()) {
      case "hourly":
        return 1;
      case "daily":
        return 2;
      case "weekly":
        return 3;
      case "monthly":
        return 4;
      case "yearly":
        return 5;
      default: return null;
    }
  }

  String getEnteredMobileNumber() {
    if(customerIdController.text.isEmpty || customerIdController.text.startsWith("+")) {
      return customerIdController.text;
    } else {
      return "${_countryCode.dialCode}${customerIdController.text}";
    }
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
