import 'dart:ui';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/kaypad.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';

class AmountScreen extends StatefulWidget {
  final AmountScreenArgument argument;

  const AmountScreen({Key key, this.argument}) : super(key: key);

  @override
  _AmountScreenState createState() => _AmountScreenState();
}

class _AmountScreenState extends State<AmountScreen> {
  final amountController = MoneyMaskedTextController(decimalSeparator: ".", thousandSeparator: ",");
  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
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
        )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Enter Amount ${widget.argument.isRequest ? 'to request' : ''}", textAlign: TextAlign.center, style: TextStyle(color: Colors.black54),),
            SizedBox(height: 16.0,),
            Container(
              color: Colors.transparent,
              child: IgnorePointer(
                child: IntrinsicWidth(
                  child: TextField(
                      textAlign: TextAlign.center,
                      controller: amountController,
                      maxLength: 15,
                      style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 32.0),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefix: Text("N "),
                        counterText: "",
                      )
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.0,),
            !widget.argument.isRequest ? Align(
              alignment: Alignment.centerRight,
              child: CircleAvatar(
                radius: 15,
                backgroundImage: NetworkImage(
                    widget.argument.photoUrl ?? "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"
                ),
              ),
            ) : SizedBox(height: 16.0,),
            SizedBox(height: 16.0,),
            !widget.argument.isRequest ? _buildSendBeneficiaryDetails(context, profileBloc) : _buildRequestBeneficiaryDetails(context),
            Expanded(
                child: Keypad(
                  listener: (String newText){
                    amountController.text = amountController.text + newText;
                  },
                  clearListener: () {
                    if(double.tryParse(amountController.text) != 0.00) {
                      amountController.text = amountController.text.substring(0, amountController.text.length - 1);
                    }
                  },
                )
            ),
            PrimaryButton(text: "Continue", pressListener: () {
              if(double.tryParse(_getUnformattedAmount()) != 0.0) {
                Navigator.pop(
                    context,
                    AmountScreenResult(formattedAmount: amountController.text,
                        amount: _getUnformattedAmount())
                );
              } else {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      behavior: SnackBarBehavior.floating,
                      content: Text("Please enter a valid amount to proceed"),
                      duration: Duration(seconds: 4)
                  ));
                });
              }
            }),
            SizedBox(height: 16.0,)
          ],
        ),
      ),
    );
  }

  String _getUnformattedAmount() {
    return amountController.text
        .replaceAll(amountController.thousandSeparator, "")
        .replaceAll(amountController.decimalSeparator, ".");
  }

  DottedBorder _buildSendBeneficiaryDetails(BuildContext context, GetMemoryProfileBloc profileBloc) {
    return DottedBorder(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            borderType: BorderType.RRect,
            radius: Radius.circular(12),
            dashPattern: const <double>[7, 3],
            color: Color(0XFFCEE6FF),
            child: Row(
              children: [
                Expanded(
                    child: StreamBuilder<BaseResponse<LoginResponse>>(
                      stream: profileBloc.stream,
                      builder: (context, snapshot) {
                        if(snapshot.data != null) {
                          final Success<LoginResponse> loginResponse = snapshot.data;
                          return LeadingText(
                            icon: Text("Payvice Balance", style: TextStyle(color: Colors.black54),),
                            textWidget: Text(
                              "N ${loginResponse.getData().balances[0].getFomrattedBalance()}", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.green, fontWeight: FontWeight.bold),
                              softWrap: false,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                            ),
                            isHorizontal: false,
                          );
                        }
                        return SizedBox.shrink();
                      }
                    )
                ),
                RawMaterialButton(
                  elevation: 4.0,
                  fillColor: Theme.of(context).primaryColor,
                  child: Icon(PayviceIcons.arrow_inclined, color: Colors.white,),
                  shape: CircleBorder(),
                ),
                Expanded(
                    child:
                    LeadingText(
                      icon: Text("Beneficiary", style: TextStyle(color: Colors.black54),),
                        isHorizontal: false,
                      isLeading: true,
                      textWidget: Text(
                          widget.argument.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Colors.black, fontWeight: FontWeight.bold,),
                        softWrap: false,
                               overflow: TextOverflow.fade,
                                 maxLines: 1,
                      )),
                )
              ],
            ),
          );
  }

  DottedBorder _buildRequestBeneficiaryDetails(BuildContext context) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: Radius.circular(12),
      dashPattern: const <double>[7, 3],
      color: Theme.of(context).primaryColor,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            color: Theme.of(context).accentColor.withAlpha(40)),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(12.0),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                      widget.argument.photoUrl ?? "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"
                  ),
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Request from",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Color(0xFF6E88A9))),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(widget.argument.name,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AmountScreenArgument {
  String name;
  bool isRequest;
  String photoUrl;
  AmountScreenArgument({this.name, this.isRequest, this.photoUrl});
}


class AmountScreenResult {
  String amount;
  String formattedAmount;
  AmountScreenResult({this.amount, this.formattedAmount});
}
