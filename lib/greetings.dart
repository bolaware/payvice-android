import 'dart:async';
import 'dart:convert';

import 'package:payvice_app/bloc/bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/cache.dart';

class Greetings {
  static String get() {
    DateTime localNow = new DateTime.now();
    final currentHour = localNow.hour;
    var greeting;
    if (currentHour >= 16) {
      greeting = "Good evening";
    } else if (currentHour >= 12) {
      greeting = "Good afternoon";
    } else {
      greeting = "Good morning";
    }
    return greeting;
  }
}