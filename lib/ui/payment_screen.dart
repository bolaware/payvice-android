import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:payvice_app/ui/screens/payment/bills_screen.dart';
import 'package:payvice_app/ui/screens/payment/recieve_screen.dart';
import 'package:payvice_app/ui/screens/payment/send_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key key}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  var _tabTextIndexSelected = 0;

  List<Widget> tabs = [SendScreen(), ReceiveScreen(), BillScreen()];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Payments",
              style: Theme.of(context).textTheme.headline3.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0,),
            FlutterToggleTab(
              width: 94,
              borderRadius: 8,
              height: 35,
              marginSelected: EdgeInsets.all(3.0),
              selectedIndex: _tabTextIndexSelected,
              selectedBackgroundColors: [Colors.white],
              selectedTextStyle: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700),
              unSelectedTextStyle: TextStyle(
                  color: Color(0xFF6E88A9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
              labels: ["Pay", "Receive", "Bills"],
              selectedLabelIndex: (index) {
                setState(() {
                  _tabTextIndexSelected = index;
                });
              },
              isScroll: false,
            ),
            Expanded(child: tabs[_tabTextIndexSelected])
          ],
        ),
      ),
    );
  }
}
