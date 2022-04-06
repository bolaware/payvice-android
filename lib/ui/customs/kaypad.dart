import 'package:flutter/material.dart';

class Keypad extends StatelessWidget {
  final Function listener;
  final Function clearListener;
  final Function extraListener;
  final IconData iconData;
  const Keypad({
    Key key,
    @required this.listener,
    @required this.clearListener,
    this.extraListener,
    this.iconData
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            KeypadTextButton(text: "1", listener: listener),
            KeypadTextButton(text: "2", listener: listener),
            KeypadTextButton(text: "3", listener: listener),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            KeypadTextButton(text: "4", listener: listener),
            KeypadTextButton(text: "5", listener: listener),
            KeypadTextButton(text: "6", listener: listener),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            KeypadTextButton(text: "7", listener: listener),
            KeypadTextButton(text: "8", listener: listener),
            KeypadTextButton(text: "9",listener: listener),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              height: 70,
              width: 70,
              child: iconData == null ? SizedBox.shrink() : GestureDetector(
                  onTap: (){
                    extraListener();
                  },
                  child: Icon(iconData, size: 36.0, color: Colors.black)
              ),
            ),
            KeypadTextButton(text: "0", listener: listener),
            Container(
              height: 70,
              width: 70,
              child: FittedBox(
                child: FloatingActionButton(
                  heroTag: "btnDelete",
                  backgroundColor: Color(0XFFF0F7FF),
                  elevation: 3,
                  child: Icon(Icons.backspace_outlined),
                  onPressed: (){
                    clearListener();
                  },
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class KeypadTextButton extends StatelessWidget {
  final String text;
  final Function listener;
  const KeypadTextButton({
    Key key,
    @required this.text,
    @required this.listener
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      child: FittedBox(
        child: FloatingActionButton(
          heroTag: "btn$text",
          onPressed: (){
            listener(text);
          },
          backgroundColor: Color(0XFFF0F7FF),
          elevation: 3,
          child: Text(text,
            style: Theme.of(context).textTheme.headline2,),
        ),
      ),
    );
  }
}