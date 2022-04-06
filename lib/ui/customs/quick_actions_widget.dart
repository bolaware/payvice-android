

import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';

class QuickActionsWidget extends StatelessWidget {
  final String text;
  final Widget iconWidget;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry paddingValue;
  final double spacingBetween;
  final Function clickListener ;

  const QuickActionsWidget({
    Key key,
    this.text,
    this.iconWidget,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.paddingValue = const EdgeInsets.all(16.0),
    this.spacingBetween = 5.0,
    this.clickListener
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Material(
        elevation: 4,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: InkWell(
          onTap: () {
            clickListener();
          },
          child: Container(
            padding: paddingValue,
            child: LeadingText(
              textWidget: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 12.0, color: Colors.black87, fontWeight: FontWeight.bold),),
              icon: iconWidget,
              isHorizontal: false,
              spacing: spacingBetween,
              crossAxisAlignment: crossAxisAlignment,
            ),
          ),
        ),
      ),
    );
  }
}