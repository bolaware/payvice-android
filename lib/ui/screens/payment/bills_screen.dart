import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bills/bills_category_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/quick_actions_widget.dart';

class BillScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  BillScreen({Key key}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final billCategoriesBloc = BillsCategoryBloc();

  @override
  void initState() {
    billCategoriesBloc.getBillsCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BillsCategoryBloc>(
      bloc: billCategoriesBloc,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            adverts(context),
            Text("Bills", style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 16.0), textAlign: TextAlign.start,),
            SizedBox(height: 16.0,),
            _getQuickActions(context),
            SizedBox(height: 16.0,),
          ],
        ),
      ),
    );
  }

  Container adverts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Theme.of(context).accentColor.withAlpha(80)
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
                  Text("Pay Bills", style: Theme.of(context).textTheme.bodyText2.copyWith(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.0,),
                  Text("Pay for your everyday needs and more", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Color(0xFF6E88A9)))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getQuickActions(BuildContext context) {
    return StreamBuilder<BaseResponse<BillsCategoryResponse>>(
        stream: billCategoriesBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            return _quickActionz(context, (result as Success<BillsCategoryResponse>).getData().categories);
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text(
                      'Error occured while fetching bills'),
                  duration: Duration(seconds: 5),
                ));
              });
            }
          } else if (result is Loading) {
              return Center(
                child: SizedBox(
                  child: CircularProgressIndicator(

                  ),
                  height: 20.0,
                  width: 20.0,
                ),
              );
          } else {}
          return SizedBox.shrink();
        }
    );
  }

  Widget _quickActionz(BuildContext context, List<BillCategory> categories) {
    List<Widget> list = [];
    if (categories.length.isOdd) categories.add(BillCategory.createDummy());
    for (int i = 0; i < categories.length; i+=2) {
      list.add(_buildMetadata(categories[i], categories[i+1]));
      list.add(SizedBox(height: 16.0,));
    }
    return Column(children: list);
  }

  Row _buildMetadata(BillCategory first, BillCategory second) {
    return Row(
      children: [
        Expanded(
          child: QuickActionsWidget(
              text: first.name,
              iconWidget: SvgPicture.network(first.image),
              clickListener: () {
                if(first.name.contains("Airtime")) {
                  Navigator.pushNamed(
                      context, PayviceRouter.airtime_screen
                  );
                } else {
                  Navigator.pushNamed(
                      context, PayviceRouter.bill_payment_screen, arguments: first
                  );
                }
              }
          ),
        ),
        SizedBox(width: 12.0,),
        Expanded(
          child: second.code != null ? QuickActionsWidget(
              text: second.name,
              iconWidget: SvgPicture.network(second.image),
              clickListener: () {
                if(second.name.contains("Airtime")) {
                  Navigator.pushNamed(
                      context, PayviceRouter.airtime_screen
                  );
                } else {
                  Navigator.pushNamed(
                      context, PayviceRouter.bill_payment_screen, arguments: second
                  );
                }
              }
          ) : SizedBox.shrink(),
        ),
      ],
    );
  }
}
