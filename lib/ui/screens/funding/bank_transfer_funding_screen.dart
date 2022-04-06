import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';

class BankTransferFundingScreen extends StatefulWidget {
  const BankTransferFundingScreen({Key key}) : super(key: key);

  @override
  _BankTransferFundingScreenState createState() => _BankTransferFundingScreenState();
}

class _BankTransferFundingScreenState extends State<BankTransferFundingScreen> {
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
            "Using bank transfer",
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
      body: StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            final customer = (snapshot.data as Success<LoginResponse>).getData().customer;
            final account = (snapshot.data as Success<LoginResponse>).getData().accountNumber;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Fund your payvice balance by transferring to your account details below",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyText1.copyWith(
                            color: Color(0xFF6E88A9)
                        )
                    ),
                  ),
                  SizedBox(height: 24.0),
                  adverts(context, account.nuban, account.bankCode == "035"),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LeadingText(
                          textWidget: Text(account.bankName.replaceAll("", "\u{200B}"), style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).primaryColorDark),),
                          icon: Text("Bank", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey)),
                          isHorizontal: false,
                          spacing: 10.0,
                          crossAxisAlignment: CrossAxisAlignment.start,
                        ),
                      ),
                      Expanded(
                        child: LeadingText(
                          textWidget: Text("${customer.firstName} ${customer.lastName}".replaceAll("", "\u{200B}"), maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).primaryColorDark),),
                          icon: Text("Account Name", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey)),
                          isHorizontal: false,
                          spacing: 10.0,
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      )
                    ],
                  ),
                  Expanded(child: SizedBox.shrink()),
                  PrimaryButton(text: "Copy account number", pressListener: () {
                    Clipboard.setData(ClipboardData(
                        text:account.nuban))
                        .then((value) {
                      final snackBar = SnackBar(
                          behavior:
                          SnackBarBehavior.floating,
                          content: Text(
                              'Account number copied!'));
                      ScaffoldMessenger.of(context)
                          .showSnackBar(snackBar);
                    });
                  }),
                  SizedBox(height: 24.0),
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }
      ),
    );
  }

  Widget adverts(BuildContext context, String accountNumber, bool isWemaBank) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Theme.of(context).accentColor.withAlpha(80)
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: isWemaBank ?
                    Image.asset('images/wema_bank_logo.png', width: 44, height: 44,) :
                  CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(PayviceIcons.send, color: Theme.of(context).accentColor,))
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Account number", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Color(0xFF6E88A9))),
                      SizedBox(height: 8.0,),
                      Text(accountNumber, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, fontSize: 20.0)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top:0.0,
          right: 0.0,
          child: Visibility(
            visible: false,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 14.0),
              child: new InkWell(
                  child: Container(
                      height: 20.0,
                      width: 20.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white
                      ),
                      child: Icon(Icons.close, size: 16.0, color: Colors.black,)
                  ),
                  onTap: () {

                  }),
            ),
          ),
        )
      ],
    );
  }
}
