import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/local_contact.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/contacts/contacts_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/services/network.dart';

class ContactsBloc implements Bloc {
  final _controller = StreamController<List<LocalContact>>.broadcast();
  final _networkclient = Network();
  final _cache = Cache();
  Stream<List<LocalContact>> get stream => _controller.stream;

  final Set<LocalContact> _contactList = {};
  final Set<FriendData> _friendList = {};

  void fetchContacts({List<PhoneContact> contacts, bool forceRemoteFetch = false}) async {
    _contactList.clear();
    _friendList.clear();

    final cachedFriends = await _cache.getPayviceFriends();

    final contactLength = await _cache.getContactListLength();

    if(cachedFriends != null && contactLength == contacts.length && !forceRemoteFetch) {
      print("CACHE CONTACT FETCH");
      fetchCachedContacts(contacts);
    } else {
      print("REMOTE CONTACT FETCH");
      fetchRemoteContacts(contacts);
    }
  }

  void fetchCachedContacts(List<PhoneContact> contacts) async {
    final json = jsonDecode(await _cache.getPayviceFriends());

    final List<FriendData> payviceFriends = [];
    json.forEach((v) {
      payviceFriends.add(new FriendData.fromJson(v));
    });

    contacts.forEach((element) {
      if(payviceFriends.map((e) => e.mobileNumber).toList().contains(element.number)) {
        final friend = payviceFriends.firstWhere((friend) => friend.mobileNumber == element.number);
        _contactList.add(friend);
      } else {
        _contactList.add(element);
      }
    });

    final displayedList = _contactList.toList();

    displayedList.sort((a, b) => a.getSearchableValue().compareTo(b.getSearchableValue()));

    _controller.sink.add(displayedList);
  }

  void fetchRemoteContacts(List<PhoneContact> contacts) async {
    final ceiling = (contacts.length/100).ceil() - 1;
    for(var i = 0; i <= ceiling; i++) {
      final max = i == ceiling ? contacts.length : 100*(i+1);
      final result = await _networkclient.getContacts(contacts.sublist(100*i, max));
      final Set<LocalContact> contactList = {};
      if (result is Success) {
        var payviceFriends = (result as Success<ContactsResponse>).getData().friendData;
        contacts.forEach((element) {
          if(payviceFriends.map((e) => e.mobileNumber).toList().contains(element.number)) {
            final friend = payviceFriends.firstWhere((friend) => friend.mobileNumber == element.number);
            contactList.add(friend);
            _friendList.add(friend);
          } else {
            contactList.add(element);
          }
        });
      } else {  }
      _contactList.addAll(contactList);
      final displayedList = _contactList.toList();
      displayedList.sort((a, b) => a.getSearchableValue().compareTo(b.getSearchableValue()));
      _controller.sink.add(displayedList);
    }
    _cache.savePayviceFriends(jsonEncode(_friendList.toList()));
    _cache.saveContactListLength(contacts.length);
  }

  void searchContacts(String value) async {
    _controller.sink.add(_contactList.where(
            (element) => element.getSearchableValue().contains(value.toLowerCase())
    ).toList());
  }

  void hasReadData(BaseResponse<LocalContact> response) {
    //_controller.sink.add(response.clone());
  }

  @override
  Loading<T> showLoading<T>() {
    return Loading();
  }

  @override
  void dispose() {
    print("DISPOSED");
    _controller.close();
  }
}