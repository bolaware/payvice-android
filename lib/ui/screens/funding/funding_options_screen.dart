import 'package:flutter/material.dart';
//import 'package:itex_pay/ui/itex_container_screen.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';

class FundingOptionScreen extends StatelessWidget {
  const FundingOptionScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            "Fund Payvice",
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Several ways to fund Payvice",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: Color(0xFF6E88A9)
                  )
              ),
            ),
            SizedBox(height: 24.0),
            _buildSettingsRow(context, "Bank Transfer", PayviceIcons.send, () {
                Navigator.pushNamed(context, PayviceRouter.bank_transfer_funding_screen);
            }),
            SizedBox(height: 8.0),
/*            _buildSettingsRow(context, "Card", PayviceIcons.credit_card, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return ItexContainerScreen();
                }),
              );
            })*/
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(BuildContext context, String title, IconData image, Function onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 2,
        color: Colors.white,
        shadowColor: Theme.of(context).primaryColor.withAlpha(50),
        borderRadius: BorderRadius.all(Radius.circular(4)),
        child: Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                      radius: 20.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(image, color: Theme.of(context).accentColor,)),
                ),
                SizedBox(width: 8.0,),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_forward_ios, size: 16.0, color: Colors.black54,),
                ),
              ],
            )
        ),
      ),
    );
  }
}
