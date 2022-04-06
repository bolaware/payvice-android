import 'package:flutter/material.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/kaypad.dart';
import 'package:payvice_app/ui/customs/onboarding_container.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';

class EnterPinScreen extends StatefulWidget {
  const EnterPinScreen({Key key}) : super(key: key);

  @override
  _EnterPinScreenState createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {

  TextEditingController controller = TextEditingController(text: "");

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey.shade200,
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
        ),
      ),
        body: OnboardingContainer(
          child: Column(
            children: [
              SizedBox(height: 16.0,),
              Text("Enter your PIN", style: Theme.of(context).textTheme.headline2,),
              Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                      "Enter your pin to validate this transaction",
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          color: Color(0xFF6E88A9)
                      )
                  )
              ),
              SizedBox(height: 16.0,),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 36.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(20),
                        right: Radius.circular(20)
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      PinCodeTextField(
                        pinBoxHeight: 50.0,
                        pinBoxWidth: 50.0,
                        pinBoxRadius: 10.0,
                        hideCharacter: true,
                        pinBoxBorderWidth: 1,
                        autofocus: false,
                        hideDefaultKeyboard: true,
                        maxLength: 4,
                        maskCharacter: "⬤",
                        pinTextStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                        onTextChanged: (String text){
                          if(text.length == 4) {
                            Navigator.pop(
                                context, controller.text
                            );
                            //showTransactionDone();
                          }
                        },
                        controller: controller,
                        defaultBorderColor: Color(0xFF0084FF),
                        pinBoxColor: Color(0xFFFCFDFF),
                        highlightPinBoxColor: Color(0xFFDCECFF),
                        hasTextBorderColor: Color(0xFF0084FF),
                      ),
                      SizedBox(height: 36.0,),
                      Expanded(
                          child: Keypad(
                            listener: (String newText){
                              if(controller.text.length != 4) {
                                controller.text = controller.text + newText;
                              }
                            },
                            clearListener: () {
                              String currentText = controller.text;
                              if(currentText != null && currentText.isNotEmpty) {
                                controller.text = currentText.substring(0, currentText.length - 1);
                              }
                            },
                          )
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        )
    );
  }
}
