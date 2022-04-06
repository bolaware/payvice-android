import 'package:flutter/material.dart';

class LeadingText extends StatelessWidget {

  bool isLeading;
  Widget textWidget;
  Widget icon;
  bool isHorizontal;
  double spacing;
  bool shouldExpand;
  CrossAxisAlignment crossAxisAlignment;


  LeadingText({
    @required this.textWidget,
    @required this.icon,
    this.isLeading = true,
    this.isHorizontal = true,
    this.spacing = 5.0,
    this.shouldExpand = false,
    this.crossAxisAlignment = CrossAxisAlignment.center
  });

  @override
  Widget build(BuildContext context) {
    return isHorizontal ? Row(
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildren()
    ) : Column(
        crossAxisAlignment: crossAxisAlignment,
        children: _buildChildren()
    );
  }

  List<Widget> _buildChildren() {
    return [
      isLeading ? icon : SizedBox.shrink(),
      isLeading ? SizedBox(width: spacing,height: spacing,) : SizedBox.shrink(),
      shouldExpand ? Expanded(child: textWidget) : textWidget,
      isLeading ? SizedBox.shrink() : SizedBox(width: spacing,height: spacing),
      isLeading ? SizedBox.shrink() : icon
    ];
  }
}