import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bills/action_on_recurring_bills_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';

class RecurringBillsDetailsScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  final RecurringBillsData data;

  RecurringBillsDetailsScreen({Key key, this.data}) : super(key: key);

  @override
  _RecurringBillsDetailsScreenState createState() => _RecurringBillsDetailsScreenState();
}

class _RecurringBillsDetailsScreenState extends State<RecurringBillsDetailsScreen> {

  final myActivitiesBloc = ActionOnRecurringBillsBloc();

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
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              adverts(context),
              SizedBox(height: 31.0,),

            ] + buildRow([
                  "Amount|N ${widget.data.getFormattedAmount()}",
                  "Reference|${widget.data.uniqueReference}",
                  "Type|${widget.data.product}",
                  "Beneficiary|${widget.data.beneficiaryNumber}",
                  "Status|${widget.data.status}",
                  "Date|${widget.data.getFormatteDate()}",
                ]) + [
              Expanded(child: SizedBox.shrink()),
              Row(
                children: [
                  widget.data.status.toLowerCase() == "active" ?
                  Expanded(
                    child: PrimaryButton(text: "Pause", pressListener: () {
                      myActivitiesBloc.actionOnRecurringBills(widget.data.id.toString(), "deactivate");
                    }),
                  ) :
                  Expanded(
                    child: PrimaryButton(text: "Resume", pressListener: () {
                      myActivitiesBloc.actionOnRecurringBills(widget.data.id.toString(), "activate");
                    }),
                  ),
                  SizedBox(width: 30.0,),
                  Expanded(
                    child: PrimaryButton(
                        text: "Delete",
                        backgroundColor: Color(0xFFF0F7FF),
                        textColor: Theme.of(context).primaryColor,
                        pressListener: () {
                          myActivitiesBloc.actionOnRecurringBills(widget.data.id.toString(), "delete");
                        }),
                  ),
                ],
              ),
              _loadConfirmationState()
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadConfirmationState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: myActivitiesBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Success).getData().message),
                ));
                Navigator.pop(context, true);
              });
              myActivitiesBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                myActivitiesBloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          } else {}
          return SizedBox.shrink();
        });
  }


  Widget adverts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Theme.of(context).accentColor.withAlpha(40)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(12.0),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                      widget.data.getLogo()
                  ),
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Description",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Color(0xFF6E88A9))),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text(
                      widget.data.product,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildRow(List<String> values) {
    if(values.length.isOdd) {
      values.add("|");
    }
    List<Widget> list = [];
    for (int i = 0; i < values.length; i+=2) {
      list.add(_buildMetadata(values[i], values[i+1]));
      list.add(SizedBox(height: 24.0,));
      list.add(Divider());
    }
    return list;
  }

  Row _buildMetadata(String first, String second) {
    return Row(
      children: [
        Expanded(
            child: LeadingText(
              icon: Text(first.split("|")[0], style: TextStyle(color: Color(0xFF6E88A9)),),
              textWidget: Text(
                first.split("|")[1], style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              isHorizontal: false,
            )
        ),
        Expanded(
          child:
          LeadingText(
              icon: Text(second.split("|")[0],
                textAlign: TextAlign.right,
                style: TextStyle(color: Color(0xFF6E88A9)),),
              isHorizontal: false,
              isLeading: true,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              textWidget: Text(
                second.split("|")[1],
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black, fontWeight: FontWeight.bold,),
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              )),
        )
      ],
    );
  }
}
