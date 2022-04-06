import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                child: Center(
                    child: SvgPicture.asset('images/payvice_onboarding.svg')),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("images/payvice_mask_onboarding.png"),
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.topCenter),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20)),
                  color: Theme.of(context).primaryColorDark,
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: StreamBuilder<BaseResponse<LoginResponse>>(
                    stream: profileBloc.stream,
                    builder: (context, snapshot) {
                      final result = snapshot.data;
                      if (result is Success) {
                        final customer =
                            (snapshot.data as Success<LoginResponse>)
                                .getData()
                                .customer;
                        return Container(
                          width: double.infinity,
                          color: Colors.white,
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text("Hello ${customer.firstName} 👋",
                                    style:
                                        Theme.of(context).textTheme.headline2,
                                    textAlign: TextAlign.center),
                              ),
                              Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 8.0),
                                  child: Text(
                                    "Welcome to payvice, paying bills just got a whole lot easier",
                                    textAlign: TextAlign.center,
                                  )),
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          color: Color(0xFFEEFDF7),
                                          border: Border.all(
                                              color: Color(0xFFD0FBE9))),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 24.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text("Get cash gifts",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline3
                                                    .copyWith(
                                                        color:
                                                            Color(0xFF00725E),
                                                        fontWeight:
                                                            FontWeight.bold),
                                                textAlign: TextAlign.center),
                                            SizedBox(
                                              height: 16.0,
                                            ),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 24.0),
                                                child: Text(
                                                    "Invite a friend now and get #100 when they sign up with your referral code",
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyText2
                                                        .copyWith(
                                                            color: Color(
                                                                0xFF00725E)),
                                                    textAlign:
                                                        TextAlign.center))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Center(
                                      child: Image.asset(
                                    'images/noto_wrapped-gift.png',
                                    width: 44,
                                    height: 44,
                                  )),
                                ],
                              ),
                              SizedBox(
                                height: 16.0,
                              ),
                              Container(
                                  padding: const EdgeInsets.all(12.0),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0)),
                                    color: Color(0xFFD0FBE9),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("payvice/${customer.mobileNumber}"),
                                      InkWell(
                                          onTap: () {
                                            Clipboard.setData(ClipboardData(
                                                    text:
                                                        "payvice/${customer.mobileNumber}"))
                                                .then((value) {
                                              final snackBar = SnackBar(
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                      'Referral link copied'));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(snackBar);
                                            });
                                          },
                                          child: LeadingText(
                                              textWidget: Text(
                                                "Copy",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              icon: Icon(Icons.copy,
                                                  color: Color(0xFF00725E)),
                                              isLeading: false))
                                    ],
                                  )),
                              SizedBox(
                                height: 16.0,
                              ),
                              Expanded(
                                child: PrimaryButton(
                                  text: "Take me to my dashboard",
                                  pressListener: () {
                                    Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        PayviceRouter.home,
                                        (Route<dynamic> route) => false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }))
          ],
        ),
      ),
    );
  }
}
