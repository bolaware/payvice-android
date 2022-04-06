import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SingleInputFieldWidget extends StatefulWidget {

  SingleInputFieldWidget({
    Key key,
    @required this.hint,
    @required this.iconData,
    this.textInputType,
    this.isPassword = false,
    this.maxLength,
    this.controller,
    this.validator,
    this.prefixWidget,
    this.maxLines = 1,
    this.autoFocus = false,
    this.isLastField = false,
    this.isPhoneNumberField = false,
    this.countryCodePickerCallback,
    this.onChanged
  }) : super(key: key);
  final String hint;
  final IconData iconData;
  final TextInputType textInputType;
  final bool isPassword;
  final int maxLength;
  final int maxLines;
  final TextEditingController controller;
  final Function validator;
  final bool isLastField;
  final bool autoFocus;
  final Widget prefixWidget;
  final bool isPhoneNumberField;
  final Function countryCodePickerCallback, onChanged;

  CountryCode _countryCode = CountryCode.fromCountryCode("NG");

  @override
  _SingleInputFieldWidgetState createState() => _SingleInputFieldWidgetState();
}

class _SingleInputFieldWidgetState extends State<SingleInputFieldWidget> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: obscureText && widget.isPassword,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      keyboardType: widget.textInputType,
      controller: widget.controller,
      autofocus: widget.autoFocus,
      validator: widget.validator,
      onChanged: (text) {
        if(widget.onChanged != null) { widget.onChanged(text); }
      },
      textInputAction: widget.isLastField ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
          labelText: widget.hint,
          errorMaxLines: 2,
          suffixIcon: GestureDetector(
            child: !widget.isPassword ? Icon(widget.iconData) : Icon(_getPasswordIcons(obscureText)),
            onTap: () {
              if(widget.isPassword)
                setState(() {
                  obscureText = !obscureText;
                });
          },),
          prefixIcon: !widget.isPhoneNumberField ? widget.prefixWidget : _getCountryCodePrefix() ,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              borderSide: BorderSide(
                color: Color(0xFF0084FF)
              )
          ),
      ),
    );
  }

  IconData _getPasswordIcons(bool isObscured) {
    return isObscured ? Icons.visibility : Icons.visibility_off;
  }

  Widget _getCountryCodePrefix() {
    return CountryCodePicker(
      initialSelection: widget._countryCode.code,
      showCountryOnly: true,
      onChanged: (CountryCode countryCode) {
        widget.countryCodePickerCallback(countryCode);
      },
      builder: (CountryCode countryCode) {
        return Container(
          width: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 8.0,),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                    countryCode.flagUri,
                    width: 30,
                    height: 15,
                    package: 'country_code_picker'
                ),
              ),
              SizedBox(width: 4.0,),
              Text(countryCode.dialCode),
              Icon(Icons.keyboard_arrow_down, size: 16.0,)
            ],
          ),
        );
      },
      flagDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
      ),
    );
  }
}


class ClickableContainer extends StatelessWidget {
  final Widget child;
  final bool isClickable;
  final Function tapListener;
  final Function tapDownListener;

  const ClickableContainer({Key key, this.child, this.isClickable = false, this.tapListener, this.tapDownListener}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var widget;
    isClickable ?
    widget = child :
    widget = GestureDetector(
      onTap: () {
        tapListener();
      },
      onTapDown: (TapDownDetails details) {
        if(tapDownListener != null) {
          tapDownListener(details);
        }
      },
      child: Container(
        color: Colors.transparent,
        child: IgnorePointer(
          child: child,
        ),
      ),
    );
    return widget;
  }
}
