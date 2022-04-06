import 'package:flutter/material.dart';

class FormContainer extends StatelessWidget {

  final Widget child;

  const FormContainer({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
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
