import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';

class BankBeneficiaryScreen extends StatefulWidget {

  final List<Beneficiary> beneficiaries;

  const BankBeneficiaryScreen({Key key, @required this.beneficiaries}) : super(key: key);

  @override
  _BankBeneficiaryScreenState createState() => _BankBeneficiaryScreenState();
}

class _BankBeneficiaryScreenState extends State<BankBeneficiaryScreen> {

  List<Beneficiary> filterBeneficiaries = [];

  final searchController = TextEditingController();

  @override
  void initState() {
    filterBeneficiaries = widget.beneficiaries;
    searchController.addListener(() {
      setState(() {
        filterBeneficiaries = widget.beneficiaries.where(
                    (element) =>
                        element.beneficiaryFullName.contains(
                            searchController.text
                        )).toList();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlue.withAlpha(160),
        elevation: 0,
        leading: Container(),
        actions: <Widget>[
          GestureDetector(
            child: Container(
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white
                ),
                child: Icon(Icons.close, size: 20.0, color: Colors.black,)
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      bottomSheet: Container(
        padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
        child: ListView.builder(
            itemCount: filterBeneficiaries.length + 4,
            itemBuilder: (context, index) {
              switch(index) {
                case 0:
                  return Text(
                    "Saved Beneficiaries",
                    style: Theme.of(context)
                        .textTheme
                        .headline3
                        .copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  );
                  break;
                case 1:
                  return SizedBox(height: 16.0,);
                  break;
                case 2:
                  return SingleInputFieldWidget(
                      hint: "Search beneficiary",
                      prefixWidget: Icon(Icons.search),
                      isLastField: true,
                      controller: searchController,
                  );
                  break;
                case 3:
                  return SizedBox(height: 16.0,);
                  break;
                default:
                  return _savedBeneficiaries(context, filterBeneficiaries[index - 4]);
                  break;
              }}),
        decoration: new BoxDecoration(
          color: Colors.white,
          borderRadius: new BorderRadius.only(
            topLeft: const Radius.circular(25.0),
            topRight: const Radius.circular(25.0),
          ),
        ),
      ),
    );
  }


  Column _savedBeneficiaries(BuildContext context, Beneficiary beneficiary) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pop(
                context,
                beneficiary
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: LeadingText(
              textWidget: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    beneficiary.beneficiaryFullName, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  Text(
                    "BANK - ${beneficiary.accountDetail}", style: Theme.of(context).textTheme.bodyText2.copyWith(color: Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis,),
                ],
              ),
              spacing: 16.0,
              icon: CircleAvatar(
                radius: 17,
                backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset("images/multi_coloured_person.svg"),
                ),
              ),
            ),
          ),
        ),
        Divider()
      ],
    );
  }
}
