import 'package:flutter/material.dart';

class ComingSoonScreen extends StatefulWidget {

  ComingSoonScreen({Key key}) : super(key: key);

  @override
  _ComingSoonScreenState createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          title: Text(
            "",
            style: Theme
                .of(context)
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
        child: Column(
          children: [
            SizedBox(height: 48.0,),
            Container(
              child: Center(
                child: Image.asset(
                  "images/onboarding_splash_1.png",
                  fit: BoxFit.fill,
                ),),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:24.0),
              child: Text(
                "Coming soon",
                style: Theme.of(context).textTheme.headline2,
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20.0,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "Our trials and triumphs became at once unique and universal, black and more than black; in chronicling our journey & stories.",
                style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9)),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        )
      ),
    );
  }
}
