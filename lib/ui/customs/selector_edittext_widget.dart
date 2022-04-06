

import 'package:flutter/material.dart';

class SelectorEditTextWidget extends StatelessWidget {
  const SelectorEditTextWidget({
    Key key,
    @required this.currentText,
    @required this.textColor,
  }) : super(key: key);

  final String currentText;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        border: Border.all(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        child: Text(
          currentText,
          style: Theme.of(context).textTheme.bodyText1.copyWith(
              color: textColor
          ),
        ),
      )
    );
  }
}