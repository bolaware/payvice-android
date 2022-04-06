import 'dart:ui';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/ui/customs/onboarding_item.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

  ValueNotifier<double> _notifier = ValueNotifier<double>(0);

  final onboardingitems = const <Widget>[
    OnboardingItem(
      onboardingData: IntroData(
          introTitle: 'Pay. Get Paid. Easy',
          introDesc: 'Pay people or have them pay you. Easy. Select from a list of Friends or saved Contacts, or, much easier, just scan a QR code.',
          imageUrl: 'images/onboarding_splash_1.png'
      ),
    ),
    OnboardingItem(
      onboardingData: IntroData(
          introTitle: 'Shop. In stores. Everywhere',
          introDesc: 'Your favorite shops are on Payvice. You can pay them same as your friends or show your QR code. You can also easily check out in-app and online',
          imageUrl: 'images/onboarding_splash_2.png'
      ),
    ),
    OnboardingItem(
      onboardingData: IntroData(
          introTitle: 'Transfer to any bank account',
          introDesc: 'Finally, bank transfers without the hassles, as long as you have your Friends and Contacts bank account number, you’re good to go.',
          imageUrl: 'images/onboarding_splash_3.png'
      ),
    ),
    OnboardingItem(
      onboardingData: IntroData(
          introTitle: 'Airtime, anything. Anytime',
          introDesc: 'Airtime, data, PHCN, DStv, StarTimes? As long as there’s a service you can pay for it with Payvice. One-off? Recurring? Whatever suits you. Plus, you can track every single penny',
          imageUrl: 'images/onboarding_splash_4.png'
      ),
    )
  ];

  int currentPage;
  PageController controller;

  Future<void> getFirebaseTokenAndSave() async {
    String token = await FirebaseMessaging.instance.getToken();
    await saveTokenToDatabase(token);
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  Future<void> saveTokenToDatabase(String token) async {
    await Cache().saveFirebaseTokenKey(token);
  }

  @override
  void initState() {
    getFirebaseTokenAndSave();
    controller = PageController(
      initialPage: 0,
      viewportFraction: 0.9,
    )..addListener(_onScroll);

    currentPage = controller.initialPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("SKIP", textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold, color: Colors.black54),),
              ),
              onTap: () {
                Navigator.pushNamed(context, PayviceRouter.sign_up);
              },
            ),
            Expanded(
              flex: 7,
              child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  children: onboardingitems,
                  onPageChanged: (int _currentPage){
                    currentPage = _currentPage;
                  },
              ),
            ),
            Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SmoothPageIndicator(
                          controller: controller,
                          count: onboardingitems.length,
                          effect: WormEffect(
                              dotHeight: 10.0,
                              dotWidth: 10.0,
                              radius: 10.0,
                              spacing: 12.0,
                              activeDotColor: Theme.of(context).accentColor,
                              dotColor: Colors.grey
                          ),
                        ),
                        PrimaryButton(
                          text : "Next",
                          pressListener: (){
                            var nextPage = onboardingitems.length - 1 == currentPage ? 0 : currentPage + 1;
                            if(nextPage == 0) {
                              Navigator.pushNamed(context, PayviceRouter.sign_up);
                            } else {
                              controller.animateToPage(
                                  nextPage,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
                            }

                          },
                        ),
                        InkWell(
                          child: RichText(
                            text: TextSpan(
                              text: 'Got an account? - ',
                              style: DefaultTextStyle.of(context).style,
                              children: const <TextSpan>[
                                TextSpan(text: 'Sign In', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0XFF67B6FF))),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, PayviceRouter.sign_in);
                          },
                        ),
                      ]
                  ),
                )
            )
          ],
        ),
      ),
    );
  }

  void _onScroll() {
    if (controller.page.toInt() == controller.page) {
      currentPage = controller.page.toInt();
    }
    setState(() {
      _notifier?.value = controller.page;
    });
  }
}