import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bills/bills_product_bloc.dart';
import 'package:payvice_app/bloc/bills/bills_provider_visibility_bloc.dart';
import 'package:payvice_app/bloc/bills/pay_bills_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/data/response/bills/bills_product_response.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/selector_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';

class BillsPaymentScreen extends StatefulWidget {
  BillCategory argument;

  final loaderWidget = LoaderWidget();

  BillsPaymentScreen({Key key, this.argument}) : super(key: key);

  @override
  _BillsPaymentScreenState createState() => _BillsPaymentScreenState();
}

class _BillsPaymentScreenState extends State<BillsPaymentScreen> {
  final billsProductBloc = BillsProductBloc();
  final payBillsBloc = PayBillsBloc();
  final billsProviderVisibilityBloc = BillsProviderVisibilityBloc();
  final serviceProviderController = TextEditingController();
  final packageController = TextEditingController();
  final customerIdController = TextEditingController();

  Map<String, List<BillsProduct>> allProviderBills;
  String selectedProvider;
  BillsProduct billsProduct;


  @override
  void initState() {
    billsProductBloc.getBillsProduct(widget.argument.code);
    billsProviderVisibilityBloc.setVisibility(false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: payBillsBloc,
      child: BlocProvider(
        bloc: billsProductBloc,
        child: BlocProvider(
          bloc: billsProviderVisibilityBloc,
          child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                automaticallyImplyLeading: false,
                centerTitle: true,
                backgroundColor: Colors.transparent,
                title: Text(
                  widget.argument.name,
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
            body: StreamBuilder<bool>(
              stream: billsProviderVisibilityBloc.visibilityStream,
              builder: (context, snapshot) {
                return FormContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _getBalance(context, profileBloc),
                      adverts(context),
                      GestureDetector(
                        onTap: () {
                          _showProviderBottomSheet(context);
                        },
                        child: _buildSelector("Service Provider", serviceProviderController),
                      ),
                      SizedBox(height: 16.0,),
                      Visibility(
                        visible: snapshot.data ?? false,
                        child: GestureDetector(
                          onTap: () {
                            _showBillsProductBottomSheet(context);
                          },
                          child: _buildSelector("Package", packageController),
                        ),
                      ),
                      SizedBox(height: 16.0,),
                      Visibility(
                        visible: snapshot.data ?? false,
                        child: SingleInputFieldWidget(
                          hint: widget.argument.getFieldName(),
                          controller: customerIdController,
                          isLastField: true,
                        ),
                      ),
                      Expanded(child: SizedBox.shrink()),
                      PrimaryButton(text: "Continue", pressListener: () async {
                        if(selectedProvider != null && billsProduct != null && serviceProviderController.text.isNotEmpty && packageController.text.isNotEmpty && customerIdController.text.isNotEmpty) {
                          final pin = await Navigator.pushNamed(
                              context, PayviceRouter.enter_pin_screen
                          );
                          if(pin == null) { return; }
                          _showConfirmation(pin);
                        }
                      }),
                      SizedBox(height: 32.0,),
                      _billsProductsStream(),
                      _sendSuccessScreen()
                    ],
                  ),
                );
              }
            ),
          ),
        ),
      )
    );
  }

  Widget _getBalance(BuildContext context, GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileBloc.stream,
        builder: (context, snapshot) {
          if(snapshot.data != null) {
            final Success<LoginResponse> loginResponse = snapshot.data;
            return Center(
              child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      color: Colors.greenAccent.withAlpha(100)),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Payvice Balance: ',
                      style: DefaultTextStyle.of(context)
                          .style
                          .copyWith(color: Colors.black54),
                      children: <TextSpan>[
                        TextSpan(
                            text: 'N ${loginResponse.getData().balances[0].getFomrattedBalance()}',
                            style: TextStyle(
                                color: Colors.green.shade600,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
            );
          }
          return SizedBox.shrink();
        }
    );
  }

  Widget _billsProductsStream() {
    return  StreamBuilder<BaseResponse<List<BillsProduct>>>(
        stream: billsProductBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            var list = result as Success<List<BillsProduct>>;
            allProviderBills = list.getData().groupBy((m) => m.providerName);
          } else if(result is Error) {

          } else {

          }
          return SizedBox.shrink();
    });
  }

  Container _buildSelector(String title, TextEditingController controller) {
    return Container(
              color: Colors.transparent,
              child: IgnorePointer(
                child: SingleInputFieldWidget(
                  hint: title,
                  controller: controller,
                  iconData: Icons.keyboard_arrow_down_rounded,
                ),
              ),
            );
  }

  Widget adverts(BuildContext context) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              color: Theme.of(context).accentColor.withAlpha(80)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.0),
                  child: Image.asset(
                    'images/internet_bill_icon.png',
                    width: 44,
                    height: 44,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.argument.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: 8.0,
                      ),
                      Text(
                          widget.argument.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Color(0xFF6E88A9)))
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0.0,
          right: 0.0,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 14.0),
            child: new InkWell(
                child: Container(
                    height: 20.0,
                    width: 20.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    child: Icon(
                      Icons.close,
                      size: 16.0,
                      color: Colors.black,
                    )),
                onTap: () {}),
          ),
        )
      ],
    );
  }

  void _showConfirmation(String pin) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Text(
                  "Confirm Transaction",
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontSize: 20.0
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'You are about to pay for ',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(text: billsProduct.name, style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.bold)),
                        TextSpan(text: ' for '),
                        TextSpan(text: 'N${billsProduct.getFormattedAmount().toString()}', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  payBillsBloc.payBills(
                      widget.argument.code.toString(),
                      billsProduct.serviceCode.toString(),
                      pin,
                      customerIdController.text
                  );

                  Navigator.pop(context);
                }),
              ]
          ),
              (){

          });
    });
  }
  
  void _showProviderBottomSheet(BuildContext context) {
    SelectorBottomSheet.showSelectorBottomSheet<String>(
        context,
        "Service Provider",
        allProviderBills.keys.toList().map((e) => BottomSheetItems<String>(title: selectedProvider, passedItem: selectedProvider)).toList().first,
        allProviderBills.keys.toList().map((e) => BottomSheetItems<String>(title: e, passedItem: e)).toList(),
        (String i) {
          selectedProvider = i;
          serviceProviderController.text = i;
          packageController.text = "";
          customerIdController.text = "";
          Navigator.pop(context);
          billsProviderVisibilityBloc.setVisibility(true);
        }
    );
  }

  void _showBillsProductBottomSheet(BuildContext context) {
    SelectorBottomSheet.showSelectorBottomSheet<BillsProduct>(
        context,
        "Provider Products",
        allProviderBills[selectedProvider].map((e) => BottomSheetItems<BillsProduct>(title: billsProduct == null ? "" : billsProduct.name, passedItem: billsProduct)).toList().first,
        allProviderBills[selectedProvider].map((e) => BottomSheetItems<BillsProduct>(title: e.name, passedItem: e)).toList(),
            (BillsProduct _billsProduct) {
              billsProduct = _billsProduct;
              packageController.text = billsProduct.name;
              customerIdController.text = "";
              Navigator.pop(context);
        }
    );
  }

  void showTransactionDone(SuccessResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Image.asset("images/pin_set_successful_icon.png", height: 90.0, width: 90.0,),
                Text(
                  "Successful!",
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontSize: 20.0
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: '${billsProduct.name}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                      children: const <TextSpan>[
                        TextSpan(text: ' successful', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(text: "See receipt", pressListener: () {
                        Navigator.pushNamed(
                            context,
                            PayviceRouter.transaction_receipt,
                            arguments: ReceiptArgument(
                              title: "Bill Payment",
                              description: billsProduct.name,
                              restOfDetails: [
                                "Amount|N ${billsProduct.getFormattedAmount()}",
                                "Reference|${response.data.payReference}",
                                "Status|${response.data.remarks}",
                                "Date|${response.data.getFormatteDate()}",
                              ]
                            )
                        );
                      }),
                    ),
                    SizedBox(width: 30.0,),
                    Expanded(
                      child: PrimaryButton(
                          text: "Okay",
                          backgroundColor: Color(0xFFF0F7FF),
                          textColor: Theme.of(context).primaryColor,
                          pressListener: () {
                            Navigator.pushNamedAndRemoveUntil(
                                context,
                                PayviceRouter.home,
                                    (Route<dynamic> route) => false
                            );
                          }),
                    ),
                  ],
                ),
              ]
          ),
              (){

          });
    });
  }

  Widget _sendSuccessScreen(){
    return StreamBuilder<BaseResponse<SuccessResponse>>(
        stream: payBillsBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showTransactionDone((result as Success<SuccessResponse>).getData());
              });
              payBillsBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text((result as Error).getError().message),
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 5)
                ));
              });
              payBillsBloc.hasReadData(result);
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          } else {}
          return SizedBox.shrink();
        }
    );
  }

}

extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) => fold(
      <K, List<E>>{},
          (Map<K, List<E>> map, E element) =>
      map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));
}

