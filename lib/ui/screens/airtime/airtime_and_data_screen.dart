import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';

class AirtimeAndDataScreen extends StatelessWidget {
  const AirtimeAndDataScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            SizedBox(
              height: 24.0,
            ),
            buildSendMoneyOption(context, "Airtime", "images/phone_circle_background_icon.svg", () {
              Navigator.pushNamed(
                  context,
                  PayviceRouter.airtime_screen
              );
            }),
            SizedBox(
              height: 12.0,
            ),
            buildSendMoneyOption(context, "Data", "images/data_circle_background.svg", () {
              Navigator.pushNamed(
                  context,
                  PayviceRouter.bill_payment_screen,
                  arguments: BillCategory(
                      code : "C02",
                      name : "Mobile Data Top-up",
                      description : "Mobile Data Top-up",
                      country : "Nigeria",
                      countryCode : "NG",
                      image : "https://payvice-images.s3.eu-central-1.amazonaws.com/internet.svg"
                  )
              );
            })
          ],
        ),
      ),
    );
  }

  Container buildSendMoneyOption(
      BuildContext context,
      String title,
      String assetName,
      Function clickListener) {
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
                  child: Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 16.0,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
