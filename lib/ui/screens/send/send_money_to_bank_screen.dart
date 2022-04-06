import 'dart:math';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/banks/account_bank_resolve_visibility_bloc.dart';
import 'package:payvice_app/bloc/banks/account_resolve_bloc.dart';
import 'package:payvice_app/bloc/banks/banks_bloc.dart';
import 'package:payvice_app/bloc/beneficiaries/bank_beneficiaries_bloc.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/send/send_money_bloc.dart';
import 'package:payvice_app/data/response/banks_list_response.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/send/account_resolve_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/general_button.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';
import 'package:payvice_app/validators.dart';

class SendMoneyToBankScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  Beneficiary alreadySelectedBeneficiary;

  SendMoneyToBankScreen({Key key, this.alreadySelectedBeneficiary}) : super(key: key);

  @override
  _SendMoneyToBankScreenState createState() => _SendMoneyToBankScreenState();
}

class _SendMoneyToBankScreenState extends State<SendMoneyToBankScreen> {
  final bankController = TextEditingController();
  final accountNumberController = TextEditingController();
  final noteController = TextEditingController();
  String bankCode;
  AmountScreenResult amountResult;
  String beneficiaryName;

  final _formKey = GlobalKey<FormState>();

  final bankBeneficiariesBloc = BankBeneficiariesBloc();
  final banksBloc = BanksBloc();
  final sendBloc = SendMoneyBloc();
  final resolveAccountBloc = AccountResolveBloc();
  final visibilityResolveAccountBloc = AccountBankResolveVisibilityBloc();

  @override
  void initState() {
    bankBeneficiariesBloc.getBeneficiaries();
    visibilityResolveAccountBloc.setVisibility(false);
    if(widget.alreadySelectedBeneficiary != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        clickedToPaySelectedBeneficiary(widget.alreadySelectedBeneficiary);
      });
    }
    super.initState();
  }

  void nullifyResolvedBankAccount() {
    visibilityResolveAccountBloc.setVisibility(false);
    beneficiaryName = null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AccountBankResolveVisibilityBloc>(
      bloc: visibilityResolveAccountBloc,
      child: BlocProvider<BankBeneficiariesBloc>(
        bloc: bankBeneficiariesBloc,
        child: BlocProvider<BanksBloc>(
          bloc: banksBloc,
          child: BlocProvider<AccountResolveBloc>(
            bloc: resolveAccountBloc,
            child: BlocProvider<SendMoneyBloc>(
              bloc: sendBloc,
              child: Scaffold(
                appBar: AppBar(
                    elevation: 0,
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    title: Text(
                      "Send Money",
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
                  child: Form(
                    key: _formKey,
                    child: FormContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _bankBeneficiary(),
                          Text("Beneficiary", style: Theme.of(context).textTheme.headline2.copyWith(fontSize: 16.0), textAlign: TextAlign.start,),
                          SizedBox(height: 24.0,),
                          GestureDetector(
                            onTap: () {
                              banksBloc.getBanks();
                              _showBanksBottomSheet(context, (Bank bank) {
                                bankController.text = bank.bankName;
                                bankCode = bank.bankCode;
                                accountNumberController.text = "";
                                nullifyResolvedBankAccount();
                              });
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: IgnorePointer(
                                child: SingleInputFieldWidget(
                                  hint: "Select Bank",
                                  controller: bankController,
                                  validator: Validators.isEmptyValid,
                                  iconData: Icons.keyboard_arrow_down_rounded,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0,),
                          SingleInputFieldWidget(
                            hint: "Account number",
                            textInputType: TextInputType.number,
                            isLastField: true,
                            controller: accountNumberController,
                            onChanged: (text) {
                              if(accountNumberController.text.length == 10) {
                                resolveAccountBloc.resolveAccountNumber(accountNumberController.text, bankCode);
                              } else {
                                nullifyResolvedBankAccount();
                              }
                            },
                            maxLength: 10,
                            validator: Validators.isAccountNumberValid,
                          ),
                          SizedBox(height: 16.0,),
                          _buildRequestBeneficiaryDetails(context),
                          Expanded(child: SizedBox.shrink()),
                          PrimaryButton(text: "Continue", pressListener: () async {
                            if(_formKey.currentState.validate() && beneficiaryName != null) {
                              final result = await Navigator.pushNamed(
                                  context,
                                  PayviceRouter.send_amount_screen,
                                  arguments: AmountScreenArgument(
                                      name: beneficiaryName, isRequest: false
                                  )
                              );

                              if(result == null) { return; }

                              amountResult = result;

                              _showConfirmation();
                            }
                          }),
                          SizedBox(height: 32.0,),
                          _sendSuccessScreen()
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _bankBeneficiary() {
    return StreamBuilder<BaseResponse<BankBeneficiaryResponse>>(
        stream: bankBeneficiariesBloc.bankBeneficiaryResponseStream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            final beneficiaries =
                (result as Success<BankBeneficiaryResponse>)
                    .getData()
                    .beneficaries
                    .where((element) => element.destination == "Bank")
                    .toList();
            if (beneficiaries.isNotEmpty) {
              return _loadBeneficariesWidget(beneficiaries);
            }
          } else {}
          return SizedBox.shrink();
        });
  }

  void clickedToPaySelectedBeneficiary(Beneficiary beneficiary) async {
    bankCode = beneficiary.bankCode;
    accountNumberController.text = beneficiary.accountDetail;
    beneficiaryName = beneficiary.beneficiaryFullName;
    final result = await Navigator.pushNamed(
        context,
        PayviceRouter.send_amount_screen,
        arguments: AmountScreenArgument(
            name: beneficiaryName, isRequest: false
        )
    );

    amountResult = result;

    _showConfirmation();
  }

  Widget _loadBeneficariesWidget(List<Beneficiary> beneficiaries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text("Choose a beneficiary", style: TextStyle(fontSize: 12, color: Colors.black54),),
        Container(
          height: 100,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: beneficiaries.length,
              itemBuilder: (context, index) {
                final beneficiary = beneficiaries[index];
                return GestureDetector(
                  onTap: () async {
                    clickedToPaySelectedBeneficiary(beneficiary);
                  },
                  child: Container(
                    margin: EdgeInsets.all(8.0),
                    child: LeadingText(
                      textWidget: Text(
                        beneficiary.beneficiaryFullName, style: Theme.of(context).textTheme.bodyText2, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,),
                      icon: Stack(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).primaryColor.withAlpha(30),
                            child: SvgPicture.asset("images/multi_coloured_person.svg"),
                          ),
                          Positioned(
                            top: 0.0, right: 0.0,
                            child: new InkWell(
                                child: Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor
                                    ),
                                    child: Icon(Icons.check, size: 16.0, color: Colors.white,)
                                ),
                                onTap: () {

                                }),
                          )
                        ],
                      ),
                      isLeading: true,
                      isHorizontal: false,
                    ),
                  ),
                );
              }
          ),
        ),
        _moreFriendsButton(beneficiaries),
      ],
    );
  }

  Row _moreFriendsButton(List<Beneficiary> beneficiaries) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GeneralButton(
          child: LeadingText(
            icon: Icon(PayviceIcons.up_right, color: Colors.black, size: 8,),
            textWidget: Text("View all", style: TextStyle(color: Colors.black, fontSize: 12.0),),
            isLeading: false,
          ),
          backgroundColor: Color(0xFFF0F7FF),
          clickListener: () async {
            final beneficiary = await Navigator.pushNamed(
                context,
                PayviceRouter.bank_beneficiary_screen,
                arguments: beneficiaries
            );


            bankCode = (beneficiary as Beneficiary).bankCode;
            accountNumberController.text = (beneficiary as Beneficiary).accountDetail;
            beneficiaryName = (beneficiary as Beneficiary).beneficiaryFullName;


            final result = await Navigator.pushNamed(
                context,
                PayviceRouter.send_amount_screen,
                arguments: AmountScreenArgument(
                    name: beneficiaryName, isRequest: false
                )
            );

            amountResult = result;

            _showConfirmation();

          },
        ),
      ],
    );
  }

  void _showBanksBottomSheet(BuildContext context, Function onBankTap) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StreamBuilder<BaseResponse<BanksListResponse>>(
          stream: banksBloc.stream,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result is Success) {
              final banks = (result as Success<BanksListResponse>).getData().banks;
              return GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Color.fromRGBO(0, 0, 0, 0.001),
                  child: GestureDetector(
                    onTap: () {},
                    child: DraggableScrollableSheet(
                      initialChildSize: 0.4,
                      minChildSize: 0.2,
                      maxChildSize: 0.75,
                      builder: (_, controller) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(25.0),
                              topRight: const Radius.circular(25.0),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.remove,
                                color: Colors.grey[600],
                              ),
                              Expanded(
                                child: ListView.separated(
                                  controller: controller,
                                  separatorBuilder: (BuildContext context, int index) => const Divider(),
                                  itemCount: banks.length,
                                  itemBuilder: (_, index) {
                                    return Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: GestureDetector(
                                            child: Text(banks[index].bankName),
                                            onTap: () {
                                              onBankTap(banks[index]);
                                              Navigator.of(context).pop();
                                            }
                                        )
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }
        );
      },
    );
  }

  void _showConfirmation() {
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
                      text: 'You are about to send ',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(text: 'N${amountResult.formattedAmount}', style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.bold)),
                        TextSpan(text: ' to '),
                        TextSpan(text: beneficiaryName, style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                SingleInputFieldWidget(
                  hint: "Note",
                  controller: noteController,
                  isLastField: true,
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  final pin = await Navigator.pushNamed(
                      context, PayviceRouter.enter_pin_screen
                  );

                  if(pin == null) { return; }

                  sendBloc.sendMoneyToAccount(
                      pin,
                      amountResult.amount,
                      noteController.text,
                      accountNumberController.text,
                      beneficiaryName,
                      bankCode
                  );

                  Navigator.pop(context);
                }),
              ]
          ),
              (){

          });
    });
  }

  Widget _sendSuccessScreen(){
    return StreamBuilder<BaseResponse<SuccessResponse>>(
        stream: sendBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showTransactionDone((result as Success<SuccessResponse>).getData());
              });
              sendBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                    duration: Duration(seconds: 5)
                ));
              });
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

  Widget _buildRequestBeneficiaryDetails(BuildContext context) {
    return StreamBuilder<BaseResponse<AccountResolveResponse>>(
      stream: resolveAccountBloc.stream,
      builder: (context, resolveSnapshot) {
        if(resolveSnapshot.data is Success) {
          visibilityResolveAccountBloc.setVisibility(true);
        }
        return StreamBuilder<bool>(
            stream: visibilityResolveAccountBloc.visibilityStream,
            builder: (context, snapshot) {
              final result = resolveSnapshot.data;
              if (result is Success) {
                final response = (result as Success<AccountResolveResponse>).getData();
                beneficiaryName = response.data.accountName;
                return Visibility(
                  visible: snapshot.data ?? false,
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    radius: Radius.circular(12),
                    dashPattern: const <double>[7, 3],
                    color: Theme.of(context).primaryColor,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          color: Theme.of(context).accentColor.withAlpha(40)),
                      child: Row(
                        children: [
                          Container(
                              padding: EdgeInsets.all(12.0),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundImage: NetworkImage(
                                    "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"),
                              )),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Account name",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(color: Color(0xFF6E88A9))),
                                SizedBox(
                                  height: 8.0,
                                ),
                                Text(beneficiaryName,
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
                  ),
                );
              }
              return SizedBox.shrink();
            }
          );
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
                  "Transfer done",
                  style: Theme.of(context).textTheme.headline2.copyWith(
                      fontSize: 20.0
                  ),
                ),
                SizedBox(height: 16.0,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'N${amountResult.formattedAmount}',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: ' is on it’s way to ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                        TextSpan(text: beneficiaryName, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                                title: "Beneficiary",
                                description: beneficiaryName,
                                restOfDetails: [
                                  "Amount|N ${amountResult.formattedAmount}",
                                  "Reference|${response.data.transactionReference}",
                                  "Account Number|${accountNumberController.text}",
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
                                context, PayviceRouter.home, (Route<dynamic> route) => false
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

  @override
  void dispose() {
    accountNumberController.dispose();
    super.dispose();
  }
}
