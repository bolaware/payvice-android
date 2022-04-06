import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class GeneralBottomSheet {

  static Future<dynamic> showSelectorBottomSheet(
      BuildContext context,
      Widget child,
      Function onTap
      ) {

    return showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Wrap(
              children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: child,
                    ),
                  )
              ],
            ),
          );
        });
  }

}