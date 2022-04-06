import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoaderWidget {
  var isShowing = false;
  String text;

  LoaderWidget({this.text = "loading.."});

  void dismiss(BuildContext context) {
    if(isShowing) {
      EasyLoading.dismiss(animation: true);
    }
  }

  Future<dynamic> showLoaderDialog<T>(BuildContext context,) async {
    isShowing = true;
    FocusManager.instance.primaryFocus.unfocus();
    EasyLoading.show(status: text, maskType: EasyLoadingMaskType.black);
  }
}