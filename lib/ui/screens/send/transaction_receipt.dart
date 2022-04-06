import 'dart:io';
import 'dart:typed_data';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/dashed_line.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_files_and_screenshot_widgets/share_files_and_screenshot_widgets.dart';

class TransactionReceipt extends StatefulWidget {
  final ReceiptArgument argument;

  TransactionReceipt({Key key, this.argument}) : super(key: key);

  @override
  _TransactionReceiptState createState() => _TransactionReceiptState();
}

class _TransactionReceiptState extends State<TransactionReceipt> {

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Screenshot(
            controller: screenshotController,
            child: Container(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 48.0),
              color: Colors.white,
              child: Column(
                children: headers() + buildRow(widget.argument.restOfDetails)
              ),
            ),
          ),
          Expanded(child: Container(color: Colors.white,)),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 48.0),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryButton(text: "Share", iconData: Icons.share, pressListener: () async {
                    screenshotController.capture().then((Uint8List capturedImage) async {
                      _askSavePermission(capturedImage);
                    }).catchError((onError) {
                      print(onError);
                    });
                  }),
                ),
                SizedBox(width: 30.0,),
                Expanded(
                  child: PrimaryButton(
                      text: "Okay",
                      backgroundColor: Color(0xFFF0F7FF),
                      textColor: Theme.of(context).primaryColor,
                      pressListener: () async {
                        Navigator.pushNamedAndRemoveUntil(
                            context, PayviceRouter.home, (Route<dynamic> route) => false
                        );
                      }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _askSavePermission(Uint8List _imageFile) async {
    var status = await Permission.storage.status;
    if (status.isGranted) {
      _saveReceipt(_imageFile);
    } else {
      await Permission.contacts.request().then((newStatus) {
        if (newStatus.isGranted) {
          _saveReceipt(_imageFile);
        } else {
          Future.delayed(Duration.zero,() {
            // _showCantProceedPermissionDialog();
          });
        }
      });
    }
  }

  _saveReceipt(Uint8List _imageFile) async {
    await ImageGallerySaver.saveImage(
        _imageFile,
        quality: 60,
        name: DateTime.now().toString());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text("Receipt saved!"),
    ));
    ShareFilesAndScreenshotWidgets().shareFile(
        'Receipt', 'receipt.jpg', _imageFile, 'image/jpg', text: 'Payvice receipt.');
  }

  List<Widget> headers() {
    return [
      Text(
        "Transaction done!",
        style: Theme.of(context).textTheme.headline2,
      ),
      Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text("See transaction summary below",
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Color(0xFF6E88A9)))),
      adverts(context),
      SizedBox(height: 16.0,),
      DashedLine(),
      SizedBox(height: 16.0,),
    ];
  }

  Widget adverts(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: Theme.of(context).accentColor.withAlpha(40)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
                padding: EdgeInsets.all(12.0),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(
                      widget.argument.photoUrl ?? "https://pickaface.net/gallery/avatar/klancaster577452311623266f9.png"),
                )),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${widget.argument.title}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(color: Color(0xFF6E88A9))),
                  SizedBox(
                    height: 8.0,
                  ),
                  Text("${widget.argument.description}",
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildRow(List<String> values) {
    if(values.length.isOdd) {
      values.add("|");
    }
    List<Widget> list = [];
    for (int i = 0; i < values.length; i+=2) {
      list.add(_buildMetadata(values[i], values[i+1]));
      list.add(SizedBox(height: 16.0,));
    }
    return list;
  }

  Row _buildMetadata(String first, String second) {
    return Row(
      children: [
        Expanded(
            child: LeadingText(
              icon: Text(first.split("|")[0], style: TextStyle(color: Color(0xFF6E88A9)),),
              textWidget: Text(
                first.split("|")[1], style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              ),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              isHorizontal: false,
            )
        ),
        Expanded(
          child:
          LeadingText(
              icon: Text(second.split("|")[0],
                textAlign: TextAlign.right,
                style: TextStyle(color: Color(0xFF6E88A9)),),
              isHorizontal: false,
              isLeading: true,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              textWidget: Text(
                second.split("|")[1],
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                  color: Colors.black, fontWeight: FontWeight.bold,),
                softWrap: false,
                overflow: TextOverflow.fade,
                maxLines: 1,
              )),
        )
      ],
    );
  }
}

class ReceiptArgument {
  final String title, description, photoUrl;
  final List<String> restOfDetails;

  ReceiptArgument({this.title, this.description, this.restOfDetails, this.photoUrl});

  static ReceiptArgument createDummy(){
    return ReceiptArgument(
        title: "Beneficiary",description: "Tosin Alade", restOfDetails: [
      "Reference Number|A09388383", "Amount|N 120,322.00",
      "Type|Airtime", "Beneficiary|Tosin Alade",
      "Status|Successful", "Date|Feb 03, 2021"
    ]
    );
  }
}
