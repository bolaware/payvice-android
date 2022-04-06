import 'package:app_settings/app_settings.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:country_code_picker/country_code.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:payvice_app/bloc/contacts/invite_friends_bloc.dart';
import 'package:payvice_app/string_extensions.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/contacts/contacts_bloc.dart';
import 'package:payvice_app/bloc/send/request_money_bloc.dart';
import 'package:payvice_app/bloc/send/send_money_bloc.dart';
import 'package:payvice_app/data/local_contact.dart';
import 'package:payvice_app/data/response/contacts/contacts_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/icons/payvice_icons_icons.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'dart:math';

import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class FriendsScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  FriendsScreen({Key key}) : super(key: key);

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  AmountScreenResult amountResult;
  FriendData friend;

  final contactsBloc = ContactsBloc();
  final sendBloc = SendMoneyBloc();
  final requestBloc = RequestMoneyBloc();
  final inviteBloc = InviteFriendsBloc();

  final searchController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    _askContactPermission();
    searchController.addListener(() {
      contactsBloc.searchContacts(searchController.text);
    });
    super.initState();
  }

  Future<void> _pullRefresh() async {
    await _fetchContacts(forceRemoteFetch: true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        bloc: contactsBloc,
        child: BlocProvider(
          bloc: sendBloc,
          child: BlocProvider(
            bloc: inviteBloc,
            child: BlocProvider(
                bloc: requestBloc,
              child: Scaffold(
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: SizedBox.shrink(),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.transparent,
                    centerTitle: true,
                    elevation: 0,
                    title: Text(
                      "Payvice Friends",
                      style: Theme.of(context)
                          .textTheme
                          .headline3
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
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
                                    hint: "Search Contacts",
                                    controller: searchController,
                                    prefixWidget: Icon(Icons.search)
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
                              if(result.isEmpty) {
                                return SliverToBoxAdapter(
                                  child: Text(searchController.text.isNotEmpty ? "No Payvice contact matching term" : "You dont have a payvice friend yet.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey),),
                                );
                              } else {
                                return SliverList(
                                    delegate: new SliverChildBuilderDelegate(
                                          (BuildContext context, int index) {
                                        return _payviceContacts(result[index]);
                                      },
                                      childCount: result.length,
                                    ));
                              }
                            } else {
                              return SliverToBoxAdapter(
                                child: SizedBox.shrink(),
                              );
                            }
                          }),
                      SliverPadding(
                        padding: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 10.0, bottom: 0.0),
                        sliver: new SliverList(
                            delegate: new SliverChildListDelegate(
                              [
                                Text("Contacts",)
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
                          }),
                      SliverToBoxAdapter(
                        child: _loadInviteConfirmationState(),
                      )
                    ]),
                  ),
              ),
            ),
          )));
  }

  Widget _payviceContacts(LocalContact friend) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    _showFriendsOptions(friend);
                  },
                  child: LeadingText(
                    textWidget: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${(friend as FriendData).firstName} ${(friend as FriendData).lastName}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .copyWith(color: Colors.black),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          (friend as FriendData).mobileNumber,
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
                    icon: Stack(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: NetworkImage(
                              (friend as FriendData).avatar ??
                              "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"
                          ),
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
                  ),
                ),
              ),
              Visibility(visible: false, child: Icon(Icons.star, color: Theme.of(context).primaryColor.withAlpha(Random().nextBool() ? 255 : 30),)),
            ],
          ),
        ),
        Divider()
      ],
    );
  }

  Column _nonPayviceFriends(BuildContext context, PhoneContact contact) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
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
              InkWell(
                onTap: () {
                  inviteBloc.invite(contact.number);
                },
                child: Text(
                  "Invite",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              )
            ],
          ),
        ),
        Divider()
      ],
    );
  }

  void _showFriendsOptions(LocalContact friend) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GeneralBottomSheet.showSelectorBottomSheet (
          context,
          Column(
              children: [
                DottedBorder(
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
                                  (friend as FriendData).avatar ??
                                  "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"),
                            )),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${(friend as FriendData).firstName}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(color: Colors.black),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "${(friend as FriendData).mobileNumber}",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText2
                                    .copyWith(color: Colors.black54),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(text: "Send money", pressListener: () {
                        Navigator.pushNamed(
                            context,
                            PayviceRouter.payvice_friends,
                            arguments: PayviceFriendsScreenArgument(
                                selectedFriend: friend, isRequest: false
                            )
                        );
                      }),
                    ),
                    SizedBox(width: 30.0,),
                    Expanded(
                      child: PrimaryButton(
                          text: "Request money",
                          backgroundColor: Color(0xFFF0F7FF),
                          textColor: Theme.of(context).primaryColor,
                          pressListener: () {
                            Navigator.pushNamed(
                                context,
                                PayviceRouter.payvice_friends,
                                arguments: PayviceFriendsScreenArgument(
                                    selectedFriend: friend, isRequest: true
                                )
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
                  duration: Duration(seconds: 1),
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
        .map((contact) => PhoneContact(
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

  Future<void> _askContactPermission() async {
    var status = await Permission.contacts.status;
    if (status.isGranted) {
      _fetchContacts();
    } else {
      await Permission.contacts.request().then((newStatus) {
        if (newStatus.isGranted) {
          _fetchContacts();
        } else {
          Future.delayed(Duration.zero,() {
            _showCantProceedPermissionDialog();
          });
        }
      });
    }
  }

  void _showCantProceedPermissionDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Contact permission is needed to see your payvice friends"),
        duration: Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(label: "Open App Settings", onPressed: (){
          //_askContactPermission();
          AppSettings.openAppSettings();
        }),
      ));
    });
  }
}
