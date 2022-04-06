import 'package:flutter/material.dart';

class OnboardingContainer extends StatelessWidget {

  final Widget child;
  final Color color;

  OnboardingContainer({Key key, this.child, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          color: color ?? Colors.grey.shade200,
          padding: const EdgeInsets.only(top: 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: child
            ),
          ),
        ),
      );
    });
  }
}
