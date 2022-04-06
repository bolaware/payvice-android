import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';

class ReferralSettingsScreen extends StatefulWidget {
  const ReferralSettingsScreen({Key key}) : super(key: key);

  @override
  _ReferralSettingsScreenState createState() => _ReferralSettingsScreenState();
}

class _ReferralSettingsScreenState extends State<ReferralSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF083061),
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(
            "Referral Rewards",
            style: Theme
                .of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold, color: Colors.white),
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
                  color: Theme
                      .of(context)
                      .primaryColorDark,
                  size: 24.0,
                ),
              ),
              shape: CircleBorder(),
            ),
          )),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Color(0xFF0084FF),
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("images/gift_blue_illustration.svg"),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Get cash gifts", style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white), textAlign: TextAlign.center),
                  ),
                  Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                      child: Text("Invite a friend now and get #100 when they sign up with your referral code", textAlign: TextAlign.center, style: TextStyle(color: Color(0xAAFFFFFF)),)
                  ),
                ]
              ),
            ),
            SizedBox(height: 16.0,),
            Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  color: Color(0xFF045AB0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text("payvice/Bolaji", style: TextStyle(color: Colors.white))),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          color: Color(0xFF22468A),
                        ),
                        padding: EdgeInsets.all(8.0),
                        child: LeadingText(textWidget: Text("Copy", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),), icon: Icon(Icons.copy, color: Colors.white), isLeading: false)
                    )
                  ],
                )
            ),
            SizedBox(height: 24.0,),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                    context,
                    PayviceRouter.referral_claim_settings_screen
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Referral Earnings", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.white)
                ],
              ),
            ),
            Expanded(child: SizedBox.shrink()),
            PrimaryButton(text: "Share", iconData: Icons.share, pressListener: () async {

            }),
            SizedBox(height: 16.0,),
          ],
        ),
      ),
    );
  }
}
