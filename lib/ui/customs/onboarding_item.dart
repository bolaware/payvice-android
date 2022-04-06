import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingItem extends StatelessWidget {
  final IntroData onboardingData;

  const OnboardingItem({
    Key key,
    @required this.onboardingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Expanded(
            child: Container(
              child: Center(
                child: Image.asset(
                  onboardingData.imageUrl,
                fit: BoxFit.fill,
              ),),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:8.0),
            child: Text(
              onboardingData.introTitle,
              style: Theme.of(context).textTheme.headline2,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 20.0,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              onboardingData.introDesc,
              style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
  }
}

class IntroData {
  final String introTitle, introDesc, imageUrl;

  const IntroData({
      @required this.introTitle,
      @required this.introDesc,
      @required this.imageUrl
  });
}
