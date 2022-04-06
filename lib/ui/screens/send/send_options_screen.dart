import 'package:app_settings/app_settings.dart';
import 'dart:math';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/onboarding/welcome_screen.dart';
import 'package:payvice_app/ui/screens/payment/recieve_screen.dart';
import 'package:payvice_app/ui/screens/payment/send_screen.dart';
import 'package:payvice_app/ui/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class SendOptionsScreen extends StatefulWidget {
  const SendOptionsScreen({Key key}) : super(key: key);

  @override
  _SendOptionsScreenState createState() => _SendOptionsScreenState();
}

class _SendOptionsScreenState extends State<SendOptionsScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(
            "Send Money",
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
            buildSendMoneyOption(context, "Send to Payvice Friend", PayviceIcons.payvice_beneficiary, () {
              _askContactPermission();
            }),
            SizedBox(height: 12.0,),
            buildSendMoneyOption(context, "Transfer out of Payvice", PayviceIcons.send, () {
              Navigator.pushNamed(
                  context, PayviceRouter.send_to_bank
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToPayviceFriends() async {
    Navigator.pushNamed(
        context, PayviceRouter.payvice_friends
    );
  }

  Container buildSendMoneyOption(
      BuildContext context,
      String title,
      IconData icon,
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
                          icon: CircleAvatar(
                            radius: 18.0,
                            backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                            child: Icon(icon, color: Color(0xFF0084FF), size: 16.0,)),
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

  Future<void> _askContactPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      _navigateToPayviceFriends();
    } else {
      await Permission.contacts.request().then((newStatus) {
        if (newStatus.isGranted) {
          _navigateToPayviceFriends();
        } else {
          Future.delayed(Duration.zero,() {
            _showCantProceedPermissionDialog();
          });
        }
      });
    }
  }

  void _showCantProceedPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Contact permission is needed to see your payvice friends"),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: "Open App Settings", onPressed: (){
          //_askContactPermission();
          AppSettings.openAppSettings();
        }),
      ));
    });
  }
}
