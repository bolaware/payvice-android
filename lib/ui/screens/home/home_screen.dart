
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/login_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/show_balance_bloc.dart';
import 'package:payvice_app/greetings.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_button.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/quick_actions_widget.dart';
import 'package:payvice_app/ui/screens/general_container_screen.dart';
import 'package:payvice_app/ui/screens/payment/bills_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  Function moreActionListener;

  HomeScreen({Key key, this.moreActionListener}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentPage;
  PageController controller;

  final showBalanceBloc = ShowBalanceBloc();

  @override
  void initState() {
    controller = PageController(
      initialPage: 0,
    );

    currentPage = controller.initialPage;
    showBalanceBloc.getShowBalanceVisibility();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: showBalanceBloc,
      child: Scaffold(
        body: SafeArea(
          child: Container(
            padding: EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _toolBar(profileBloc),
                  SizedBox(height: 10.0),
                  StreamBuilder<bool>(
                      stream: showBalanceBloc.stream,
                      initialData: false,
                      builder: (context, snapshot) {
                        return buildWalletBalances(profileBloc, snapshot.data, () {
                          showBalanceBloc.switchVisibility();
                        });
                      }
                  ),
                  adverts(context),
                  Text("Quick Actions", style: Theme.of(context).textTheme.headline2, textAlign: TextAlign.start,),
                  SizedBox(height: 10.0),
                  _quickActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolBar(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
      stream: profileBloc.stream,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is Success) {
          final customer = (snapshot.data as Success<LoginResponse>).getData().customer;
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context,
                      PayviceRouter.edit_profile_screen
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      color: Theme.of(context).accentColor.withAlpha(120),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(22), topRight: Radius.circular(22), bottomRight: Radius.circular(22))
                  ),
                  child: CircleAvatar(
                    radius: 17.0,
                    foregroundImage: NetworkImage(customer.getAvatar()),
                    backgroundColor: Colors.white,
                    child: SvgPicture.asset("images/home_user_icon.svg"),
                  ),
                ),
              ),
              Expanded(child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: Greetings.get() + ", ",
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(text: customer.firstName, style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.notification_screen
                  );
                },
                child: Container(
                    padding: EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).accentColor.withAlpha(120),
                        borderRadius: BorderRadius.all(Radius.circular(5.0))
                    ),
                    child: Icon(PayviceIcons.notifications, color: Theme.of(context).primaryColor)),
              )
            ],
          );
        }
        return SizedBox.shrink();
      }
    );
  }

  Widget buildWalletBalances(GetMemoryProfileBloc profileBloc, bool showBalance, Function balanceVisibilitySwitched) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
      stream: profileBloc.stream,
      builder: (context, snapshot) {
        final result = snapshot.data;
        if (result is Success) {
          final balances = (snapshot.data as Success<LoginResponse>).getData().balances;
          return Container(
            height: 110,
            child: Stack(
              children: [
                PageView(
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  children: balances.map((e) => BalanceHeaderWidget(balance: e, showBalance: showBalance, balanceVisibilitySwitched: balanceVisibilitySwitched)).toList(),
                  onPageChanged: (int _currentPage){
                    currentPage = _currentPage;
                  },
                ),
                Positioned.fill(
                  bottom: 8.0,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                        controller: controller,
                        count: balances.length,
                        effect: ScrollingDotsEffect(
                            dotHeight: 6.0,
                            dotWidth: 6.0,
                            radius: 6.0,
                            spacing: 4.0,
                            activeDotColor: Colors.white,
                            dotColor: Colors.white.withAlpha(120)
                        )
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox.shrink();
      }
    );
  }

  Container adverts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Color(0xFFEEFDF7)
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.0),
              child: Image.asset('images/noto_blue_wrapped-gift.png', width: 44, height: 44,),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Payments just got easier", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0,),
                  Text("Complete the to-do &  get on the groove", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Color(0xFF6E88A9)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column _quickActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: QuickActionsWidget(
                text: "Pay Bills",
                iconWidget: CircleAvatar(
                    radius: 24.0,
                    backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                    child: Icon(PayviceIcons.utility, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.general_container_screen, arguments: GeneralContainerScreenArg(title: "Bills", child: BillScreen())
                  );
                },
              ),
            ),
            SizedBox(width: 12.0,),
            Expanded(
              child: QuickActionsWidget(
                  text: "QR Code",
                  iconWidget: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(PayviceIcons.qr_code, color: Theme.of(context).accentColor,)),
                  clickListener: () {
                    Navigator.pushNamed(
                        context, PayviceRouter.coming_soon_screen
                    );
                  }
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0,),
        Row(
          children: [
            Expanded(
              child: QuickActionsWidget(
                  text: "Request money",
                  //iconWidget: SvgPicture.asset("images/tolls.svg"),
                  iconWidget: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(PayviceIcons.download_1, color: Theme.of(context).accentColor,)),
                clickListener: () {
                  Navigator.pushNamed(
                      context, PayviceRouter.payvice_friends, arguments: PayviceFriendsScreenArgument(isRequest: true)
                  );
                },
              ),
            ),
            SizedBox(width: 12.0,),
            Expanded(
              child: QuickActionsWidget(
                  text: "Send money",
                  iconWidget: CircleAvatar(
                      radius: 24.0,
                      backgroundColor: Theme.of(context).accentColor.withAlpha(120),
                      child: Icon(PayviceIcons.send, color: Theme.of(context).accentColor,)),
                  clickListener: () {
                    Navigator.pushNamed(
                        context, PayviceRouter.send_options_screen
                    );
                  },
              ),
            ),
          ],
        ),
        SizedBox(height: 24.0,),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GeneralButton(
              clickListener: () {
                widget.moreActionListener();
              },
              child: LeadingText(
                icon: Icon(PayviceIcons.up_right, color: Colors.black, size: 12,),
                textWidget: Text("More actions", style: TextStyle(color: Colors.black),),
                isLeading: false,
              ),
              backgroundColor: Color(0xFFF0F7FF),
            ),
          ],
        )
      ],
    );
  }
}


class BalanceHeaderWidget extends StatelessWidget {
  final Balance balance;
  final bool showBalance;
  final Function balanceVisibilitySwitched;

  BalanceHeaderWidget({Key key, this.balance, this.showBalance, this.balanceVisibilitySwitched}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 25.0, right: 10.0),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/payvice_mask_onboarding.png'),
          fit: BoxFit.cover,
          alignment: Alignment.bottomLeft
        ),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Theme.of(context).primaryColorDark,
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LeadingText(
                    icon: GestureDetector(
                        onTap: () {
                          balanceVisibilitySwitched();
                        },
                        child: Icon(showBalance ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white, size: 16.0,)
                    ),
                    textWidget: Text("Payvice Balance", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                    isLeading: false,
                    spacing: 5.0,
                  ),
                  GeneralButton(
                      child: LeadingText(
                        icon: Icon(Icons.add, color: Colors.white, size: 16.0,),
                        textWidget: Text("Fund Payvice", textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                        isLeading: false,
                        spacing: 2.0,
                      ),
                      clickListener: () {
                        Navigator.pushNamed(context, PayviceRouter.funding_options_screen);
                      }
                  )
                ],
              ),
              Text(showBalance ? "N${balance.getFomrattedBalance()}" : "--.--", style: Theme.of(context).textTheme.headline2.copyWith(color: Colors.white),)
            ],
          )
        ],
      ),
    );
  }
}

