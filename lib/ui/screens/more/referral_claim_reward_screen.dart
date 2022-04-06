import 'package:flutter/material.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';

class ReferralClaimRewardScreen extends StatefulWidget {
  const ReferralClaimRewardScreen({Key key}) : super(key: key);

  @override
  _ReferralClaimRewardScreenState createState() => _ReferralClaimRewardScreenState();
}

class _ReferralClaimRewardScreenState extends State<ReferralClaimRewardScreen> {
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
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                child: Text("Unclaimed Rewards 💵", textAlign: TextAlign.center, style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 16.0),)
            ),
            SizedBox(height: 16.0,),
            Text("N200.00", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white)),
            SizedBox(height: 16.0,),
            Container(
              height: 38.0,
              width: 73.0,
              child: PrimaryButton(text: "Claim Reward", width: 150.0, pressListener: () async {

              }),
            ),
            SizedBox(height: 32.0,),
            getRow("Referred People", "1", "Amount per referral", "200"),
            getRow("Total Earned", "N200,000", "Total Unclaimed", "N200"),
            Divider(color: Color(0xFFF0F7FF)),
            Row(
              children: [
                Expanded(child: Text("Next automated payout date", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9)),)),
                Expanded(child: Text("22nd June, 2021", textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white),)),
              ],
            ),
            Expanded(child: SizedBox.shrink(),),
            Text("Doing great! Invite more friends \nand earn more.", textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)),
            Expanded(child: SizedBox.shrink(),),
          ],
        ),
      ),
    );
  }

  Widget getRow(String firstTitle, String firstValue, String secondTitle, String secondValue) {
    return Column(
      children: [
        Divider(color: Color(0xFFF0F7FF)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              LeadingText(crossAxisAlignment: CrossAxisAlignment.start, textWidget: Text(firstTitle, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white.withAlpha(120))), icon: Text(firstValue, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)), isHorizontal: false, isLeading: false, ),
              Expanded(child: SizedBox.shrink(),),
              LeadingText(crossAxisAlignment: CrossAxisAlignment.end, textWidget: Text(secondTitle, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white.withAlpha(120))), icon: Text(secondValue, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.white)), isHorizontal: false, isLeading: false,)
            ],
          ),
        ),
      ],
    );
  }

}
