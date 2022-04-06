import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bills/recurring_bills_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';

class RecurringBillsScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();

  RecurringBillsScreen({Key key}) : super(key: key);

  @override
  _RecurringBillsScreenState createState() => _RecurringBillsScreenState();
}

class _RecurringBillsScreenState extends State<RecurringBillsScreen> {
  final myActivitiesBloc = RecurringBillsBloc();

  final searchController = TextEditingController();

  @override
  void initState() {
    myActivitiesBloc.getRecurringBills();
    searchController.addListener(() {
      myActivitiesBloc.searchContacts(searchController.text);
    });
    super.initState();
  }

  Future<void> _pullRefresh() async {
    await myActivitiesBloc.getRecurringBills();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: myActivitiesBloc,
        child: Scaffold(
          appBar: AppBar(
              elevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                "Recurring bills",
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
          body: RefreshIndicator(
            onRefresh: _pullRefresh,
            child: CustomScrollView(slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 10.0, bottom: 20.0),
                sliver: new SliverList(
                    delegate: new SliverChildListDelegate(
                  [
                    SingleInputFieldWidget(
                        isLastField: true,
                        hint: "Search bills",
                        controller: searchController,
                        prefixWidget: Icon(Icons.search)),
                  ],
                )),
              ),
              StreamBuilder<BaseResponse<RecurringBillsResponse>>(
                  stream: myActivitiesBloc.stream,
                  builder: (context, snapshot) {
                    if (snapshot.data is Success) {
                      final activityData =
                          (snapshot.data as Success<RecurringBillsResponse>)
                              .getData()
                              .data;
                      if (activityData.isEmpty) {
                        return SliverToBoxAdapter(
                          child: Text(
                            searchController.text.isNotEmpty
                                ? "No bills matching term"
                                : "You don't have any recurring bills yet.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      } else {
                        return SliverList(
                            delegate: new SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return _transactionsItem(activityData[index]);
                          },
                          childCount: activityData.length,
                        ));
                      }
                    } else {
                      return SliverToBoxAdapter(
                        child: snapshot.data is Loading ? Center(child: CircularProgressIndicator()) : SizedBox.shrink(),
                      );
                    }
                  }),
            ]),
          ),
        ));
  }

  Widget _transactionsItem(RecurringBillsData billData) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.pushNamed(
            context, PayviceRouter.recurring_bills_details_screen, arguments: billData
        );

        if(result != null) { _pullRefresh(); }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17.0,
                  foregroundImage: NetworkImage(
                      billData.getLogo()
                  ),
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 16.0,),
                Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(billData.product, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Theme.of(context).primaryColorDark)),
                    Text(billData.frequency, style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.grey))
                  ],
                )),
                Text("N${billData.amount.toString()}", style: Theme.of(context).textTheme.titleSmall.copyWith(color: Theme.of(context).primaryColorDark))
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
