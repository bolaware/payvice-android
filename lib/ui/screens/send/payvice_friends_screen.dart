import 'dart:ui';
import 'package:contacts_service/contacts_service.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/contacts/invite_friends_bloc.dart';
import 'package:payvice_app/string_extensions.dart';
import 'package:payvice_app/bloc/contacts/contacts_bloc.dart';
import 'package:payvice_app/bloc/send/request_money_bloc.dart';
import 'package:payvice_app/bloc/send/send_money_bloc.dart';
import 'package:payvice_app/data/local_contact.dart';
import 'package:payvice_app/data/response/contacts/contacts_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/airtime/airtime_screen.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';

class PayviceFriendsScreen extends StatefulWidget {
  final PayviceFriendsScreenArgument argument;

  final loaderWidget = LoaderWidget();

  PayviceFriendsScreen({Key key, this.argument}) : super(key: key);

  @override
  _PayviceFriendsScreenState createState() => _PayviceFriendsScreenState();
}

class _PayviceFriendsScreenState extends State<PayviceFriendsScreen> {
  final contactsBloc = ContactsBloc();
  final sendBloc = SendMoneyBloc();
  final requestBloc = RequestMoneyBloc();
  final inviteBloc = InviteFriendsBloc();

  AmountScreenResult amountResult;
  FriendData friend;

  final searchController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    _fetchContacts();
    searchController.addListener(() {
      contactsBloc.searchContacts(searchController.text);
    });

    if(widget.argument.selectedFriend != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        proceedToAmount(widget.argument.selectedFriend);
      });
    }

    super.initState();
  }

  Future<void> _pullRefresh() async {
    _fetchContacts(forceRemoteFetch: true);
  }

  void proceedToAmount(FriendData _friend) async {
    final result = await Navigator.pushNamed(context, PayviceRouter.send_amount_screen,
        arguments: AmountScreenArgument(
            name: _friend.firstName, isRequest: widget.argument.isRequest, photoUrl: _friend.avatar
        ));

    if(result == null) { return; }

    amountResult = result;
    friend = _friend;

    _showConfirmation();
  }

  Future<void> _fetchContacts({bool forceRemoteFetch = false}) async {
    Iterable<Contact> contacts =
        await ContactsService.getContacts(withThumbnails: false);

    String country;

    try {
      country = await FlutterSimCountryCode.simCountryCode;
    } catch(e) {
      country = "NG";
    }

    var phoneContacts = contacts
        .toList()
        .where((element) => element.phones.isNotEmpty)
        .map((contact) =>
        PhoneContact(
            name: contact.displayName,
            number:
            contact.phones.first.value
                .replaceAll("-", "")
                .replaceAll(" ", "")
                .removeFirstZeroInPhoneNumber(
                  CountryCode.fromCountryCode(country).dialCode
            )
        ))
        .toList();

    final numbersList = phoneContacts.map((e) => e.number).toSet();
    phoneContacts.retainWhere((x) => numbersList.remove(x.number));

    contactsBloc.fetchContacts(contacts: phoneContacts, forceRemoteFetch: forceRemoteFetch);
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
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: Icon(
                  Icons.close,
                  size: 20.0,
                  color: Colors.black,
                )),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      bottomSheet: BlocProvider<ContactsBloc>(
        bloc: contactsBloc,
        child: BlocProvider<SendMoneyBloc>(
          bloc: sendBloc,
          child: BlocProvider<RequestMoneyBloc>(
            bloc: requestBloc,
            child: BlocProvider<InviteFriendsBloc>(
              bloc: inviteBloc,
              child: RefreshIndicator(
                onRefresh: _pullRefresh,
                child: Container(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: CustomScrollView(slivers: <Widget>[
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
                      sliver: new SliverList(
                          delegate: new SliverChildListDelegate(
                        [
                          Text(
                            widget.argument.isRequest
                                ? "Choose friend to request from"
                                : "Payvice Friends",
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          SingleInputFieldWidget(
                            hint: "Search Contacts",
                            prefixWidget: Icon(Icons.search),
                            isLastField: true,
                            controller: searchController,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                        ],
                      )),
                    ),
                    StreamBuilder<List<LocalContact>>(
                        stream: contactsBloc.stream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {

                            final result = snapshot.data
                                .where((element) => element is FriendData)
                                .toList();

                            return SliverPadding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
                              sliver: new SliverList(
                                  delegate: new SliverChildListDelegate(
                                    [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          "Payvice Contacts",
                                        ),
                                      ),
                                      Visibility(
                                        visible: result.isEmpty,
                                        child: Text(searchController.text.isNotEmpty ? "No Payvice contact matching term" : "You dont have a payvice friend yet.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                                      ),
                                      Visibility(
                                          visible: result.isNotEmpty,
                                          child: _payViceContacts(result)
                                      )
                                    ],
                                  )),
                            );
                          }
                          return SliverToBoxAdapter(
                            child: SizedBox.shrink(),
                          );
                        }),
                    SliverPadding(
                      padding: const EdgeInsets.only(
                          left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
                      sliver: new SliverList(
                          delegate: new SliverChildListDelegate(
                            [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  "Contacts",
                                ),
                              )
                            ],
                          )),
                    ),
                    StreamBuilder<List<LocalContact>>(
                        stream: contactsBloc.stream,
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            final result = snapshot.data
                                .where((element) => element is PhoneContact)
                                .toList();
                            if(result.isEmpty && searchController.text.isNotEmpty) {
                              return SliverToBoxAdapter(
                                child: Text("No contact matching term", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),
                              );
                            } else {
                              return SliverList(
                                  delegate: new SliverChildBuilderDelegate(
                                        (BuildContext context, int index) {
                                      return _nonPayviceFriends(
                                          context,
                                          PhoneContact(
                                              name: (result[index] as PhoneContact).name,
                                              number: (result[index] as PhoneContact).number));
                                    },
                                    childCount: result.length,
                                  ));
                            }
                          } else {
                            return SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            );
                          }
                        })
                  ]),
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _sendSuccessScreen(),
          _requestSuccessScreen(),
          _loadInviteConfirmationState()
        ],
      ),
    );
  }

  Widget _payViceContacts(List<LocalContact> friends) {
    return Container(
      height: 100,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: friends.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () async {
                if(widget.argument.forSelectionPurpose) {
                  var friend = friends[index] as FriendData;
                  Navigator.pop(
                      context,
                      AirtimeDataBeneficiary(name: "${friend.firstName} ${friend.lastName}", number: friend.mobileNumber, photoUrl: friend.avatar)
                  );
                  return;
                }
                proceedToAmount((friends[index] as FriendData));
              },
              child: Container(
                margin: EdgeInsets.all(8.0),
                child: LeadingText(
                  textWidget: Text(
                    (friends[index] as FriendData).firstName,
                    style: Theme.of(context).textTheme.bodyText2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  icon: Stack(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                            (friends[index] as FriendData).avatar ??
                            "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"),
                      ),
                      Positioned(
                        top: 0.0,
                        right: 0.0,
                        child: new InkWell(
                            child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).primaryColor),
                                child: Icon(
                                  Icons.check,
                                  size: 16.0,
                                  color: Colors.white,
                                )),
                            onTap: () {}),
                      )
                    ],
                  ),
                  isLeading: true,
                  isHorizontal: false,
                ),
              ),
            );
          }),
    );
  }

  Widget _nonPayviceFriends(BuildContext context, PhoneContact contact) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: (){
                    if(widget.argument.forSelectionPurpose) {
                      Navigator.pop(
                          context,
                          AirtimeDataBeneficiary(name: contact.name, number: contact.number)
                      );
                    }
                  },
                  child: LeadingText(
                    textWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          contact.number,
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              .copyWith(color: Colors.black54),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    spacing: 16.0,
                    icon: CircleAvatar(
                      radius: 17.0,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, color: Colors.grey.shade800),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: widget.argument.forSelectionPurpose,
                child: InkWell(
                  onTap: () {
                    inviteBloc.invite(contact.number);
                  },
                  child: Text(
                    "Invite",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }

  Widget _loadInviteConfirmationState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: inviteBloc.stream,
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
              });
              inviteBloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                inviteBloc.hasReadData(result);
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

  void _showConfirmation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Text(
                  "Confirm ${!widget.argument.isRequest ? 'Transaction' : 'Request'}",
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
                      text: 'You are about to ${!widget.argument.isRequest ? 'send' : 'request'} ',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey),
                      children: <TextSpan>[
                        TextSpan(text: 'N${amountResult.formattedAmount}', style: TextStyle(color: Color(0xFF0084FF), fontWeight: FontWeight.bold)),
                        TextSpan(text: ' ${!widget.argument.isRequest ? "to" : "from"}\n'),
                        TextSpan(text: "${friend.firstName} ${friend.lastName}", style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                SingleInputFieldWidget(
                  hint: "${widget.argument.isRequest ? 'Reason' : 'Add a note(optional)'}",
                  controller: noteController,
                  isLastField: true,
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(text: "Continue", pressListener: () async {
                  if(widget.argument.isRequest) {
                    requestBloc.requestMoneyToPayvice(
                        amountResult.amount,
                        noteController.text,
                        friend.mobileNumber
                    );
                  } else {
                    final pin = await Navigator.pushNamed(
                        context, PayviceRouter.enter_pin_screen
                    );

                    if(pin == null) { return; }

                    sendBloc.sendMoneyToPayvice(
                        pin,
                        amountResult.amount,
                        noteController.text,
                        friend.mobileNumber,
                        "${friend.firstName} ${friend.lastName}"
                    );
                  }


                  Navigator.pop(context);
                }),
              ]
          ),
              (){

          });
    });
  }

  Widget _requestSuccessScreen(){
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: requestBloc.stream,
        builder: (context, snapshot) {
          return requestSuccessScreen(context, snapshot);
        }
    );
  }

  Widget _sendSuccessScreen(){
    return StreamBuilder<BaseResponse<SuccessResponse>>(
        stream: sendBloc.stream,
        builder: (context, snapshot) {
          return successScreen(context, snapshot);
        }
    );
  }

  Widget requestSuccessScreen(context, AsyncSnapshot<BaseResponse<GenericResponse>> snapshot) {
    final result = snapshot.data;
    if (result is Success) {
      widget.loaderWidget.dismiss(context);
      if (!result.hasReadData) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showRequestTransactionDone((result as Success<GenericResponse>).getData());
        });
        requestBloc.hasReadData(result);
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

  Widget successScreen(context, AsyncSnapshot<BaseResponse<SuccessResponse>> snapshot) {
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

  void showRequestTransactionDone(GenericResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Image.asset("images/pin_set_successful_icon.png", height: 90.0, width: 90.0,),
                Text(
                  '${widget.argument.isRequest ? "Request sent" : "Transfer done"}',
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
                      text: 'N${amountResult.formattedAmount}',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: ' ${widget.argument.isRequest ? 'has been requested from' : 'is on it’s way to'} ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                        TextSpan(text: "${friend.firstName} ${friend.lastName}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                PrimaryButton(
                    text: "Okay",
                    pressListener: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, PayviceRouter.home, (Route<dynamic> route) => false
                      );
                    }),
              ]
          ),
              (){

          });
    });
  }

  void showTransactionDone(SuccessResponse response) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                Image.asset("images/pin_set_successful_icon.png", height: 90.0, width: 90.0,),
                Text(
                  '${widget.argument.isRequest ? "Request sent" : "Transfer done"}',
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
                      text: 'N${amountResult.formattedAmount}',
                      style: DefaultTextStyle.of(context).style.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                      children: <TextSpan>[
                        TextSpan(text: ' ${widget.argument.isRequest ? 'has been requested from' : 'is on it’s way to'} ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.normal)),
                        TextSpan(text: "${friend.firstName} ${friend.lastName}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
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
                                description: friend.firstName + " " + friend.lastName,
                                photoUrl: friend.avatar,
                                restOfDetails: [
                                  "Amount|N ${amountResult.formattedAmount}",
                                  "Reference|${response.data.transactionReference}",
                                  "Mobile Number|${friend.mobileNumber}",
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
}

class PayviceFriendsScreenArgument{
  bool isRequest;
  FriendData selectedFriend;
  bool forSelectionPurpose;
  PayviceFriendsScreenArgument({this.isRequest = false, this.selectedFriend, this.forSelectionPurpose = false});
}
