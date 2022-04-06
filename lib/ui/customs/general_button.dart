import 'package:flutter/material.dart';

class GeneralButton extends StatelessWidget {
  Widget child;
  double borderRadius;
  Color backgroundColor;
  Function clickListener;
  Color shadowColour;

  GeneralButton({
    @required this.child,
    this.backgroundColor,
    this.borderRadius,
    this.clickListener,
    this.shadowColour
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        child: child,
        onPressed: () {
          clickListener();
        },
        style: Theme
            .of(context)
            .elevatedButtonTheme
            .style
            .copyWith(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius == null ? 8.0 : borderRadius),
              )
          ),
          backgroundColor: MaterialStateProperty.all<Color>(
              backgroundColor == null ? Theme.of(context).primaryColor : backgroundColor
          ),
          overlayColor: MaterialStateProperty.all<Color>(
              backgroundColor == null ? Theme.of(context).primaryColor.withAlpha(90) : backgroundColor.withAlpha(90)
          ),
          shadowColor: MaterialStateProperty.all<Color>(
              shadowColour
          ),
        )
    );
  }
}