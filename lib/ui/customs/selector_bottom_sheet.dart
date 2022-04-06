

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SelectorBottomSheet {

  static Future<dynamic> showSelectorBottomSheet<T>(
      BuildContext context,
      String title,
      BottomSheetItems currentItemSelected,
      List<BottomSheetItems> options, Function onTap) {

    return showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: true,
        isDismissible: true,
        backgroundColor: Colors.white,
        builder: (BuildContext context) {
          return SafeArea(
            child: Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 16.0),
                  child: Text(title, style: Theme.of(context).textTheme.headline3.copyWith(fontSize: 16.0)),
                ),
                Divider(),
                SingleChildScrollView(
                  child: Column(
                    children: options
                        .map<Widget>((item) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(child: GestureDetector(
                              child: Text(item.title),
                              onTap: () {
                                onTap(item.passedItem);
                              }
                          )),
                          if (item.title == currentItemSelected.title)
                            Icon(Icons.check)
                          else
                            SizedBox.shrink()
                        ],
                      ),
                    )).toList(),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                  ),
                )
              ],
            ),
          );
        });
  }

}

class BottomSheetItems<T> {
  final String title;
  final T passedItem;

  const BottomSheetItems({this.title, this.passedItem});
}