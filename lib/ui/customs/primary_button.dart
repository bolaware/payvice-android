import 'dart:ui';

import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    Key key,
    @required this.text,
    @required this.pressListener,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.iconData,
    this.width = double.infinity
  }) : super(key: key);

  final Function pressListener;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final IconData iconData;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: width,
        height: 50.00,
        child: ElevatedButton(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              iconData != null ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(iconData),
              ) : SizedBox.shrink(),
              Text(
                text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
              ),)
            ],
          ),
          style: Theme.of(context).elevatedButtonTheme.style.copyWith(
            backgroundColor: MaterialStateProperty.all<Color>(
                backgroundColor == null ? Theme.of(context).primaryColor : backgroundColor
            ),
          ),
          onPressed: () {
            pressListener();
          },
        ),
      ),
    );
  }
}