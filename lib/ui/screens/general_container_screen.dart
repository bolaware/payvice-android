import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GeneralContainerScreen extends StatelessWidget {

  final GeneralContainerScreenArg arg;

  const GeneralContainerScreen({Key key, this.arg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          title: Text(
            this.arg.title,
            style: Theme.of(context)
                .textTheme
                .headline3
                .copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RawMaterialButton(
              onPressed: () {
                Navigator.pop(context);
              },
              elevation: 2.0,
              fillColor: Color(0xFFEFF6FE),
              child: Center(
                child: Icon(
                  Icons.arrow_back,
                  color: Theme.of(context).primaryColorDark,
                  size: 24.0,
                ),
              ),
              shape: CircleBorder(),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: this.arg.child,
      ),
    );
  }
}


class GeneralContainerScreenArg{
  final String title;
  final Widget child;

  GeneralContainerScreenArg({this.child, this.title});
}