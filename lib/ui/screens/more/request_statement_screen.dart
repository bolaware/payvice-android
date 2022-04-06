import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:intl/intl.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/more/request_statement_bloc.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';
import 'package:payvice_app/validators.dart';

class RequestStatementScreen extends StatefulWidget {
  final loaderWidget = LoaderWidget();
  
  RequestStatementScreen({Key key}) : super(key: key);

  @override
  _RequestStatementScreenState createState() => _RequestStatementScreenState();
}

class _RequestStatementScreenState extends State<RequestStatementScreen> {


  final _formKey = GlobalKey<FormState>();

  final typeController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  DateFormat outputFormat = DateFormat("yyyy-MM-dd");

  bool isPaymentSelected = false;
  bool isRequestSelected = true;
  bool isBillsSelected = true;

  DateTime selectedStartDate = DateTime.now();
  DateTime selectedEndDate = DateTime.now();

  final bloc = RequestStatementBloc();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              "Request Statement",
              style: Theme
                  .of(context)
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
                    color: Theme
                        .of(context)
                        .primaryColorDark,
                    size: 24.0,
                  ),
                ),
                shape: CircleBorder(),
              ),
            )),
        body: Container(
          child: Form(
            key: _formKey,
            child: FormContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 24.0,),
                  Visibility(
                    visible: false,
                    child: ClickableContainer(
                      tapListener: () {
                        _showConfirmation2("Select transactions");
                      },
                      child: SingleInputFieldWidget(
                        hint: "Select transaction category",
                        controller: typeController,
                        validator: Validators.isEmptyValid,
                        iconData: Icons.keyboard_arrow_down_rounded,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.0,),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context, true);
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: SingleInputFieldWidget(
                                hint: "Start Date",
                                controller: startDateController,
                                validator: Validators.isEmptyValid,
                                iconData: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.0,),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _selectDate(context, false);
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: IgnorePointer(
                              child: SingleInputFieldWidget(
                                hint: "End Date",
                                controller: endDateController,
                                validator: Validators.isEmptyValid,
                                iconData: Icons.calendar_today_outlined,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox.shrink()),
                  PrimaryButton(text: "Continue", pressListener: () async {
                    if (_formKey.currentState.validate()) {
                      bloc.requestStatement(
                          outputFormat.format(selectedStartDate) + "T00:00:00.000Z",
                          outputFormat.format(selectedEndDate) + "T23:59:00.000Z"
                      );
                    }
                  }),
                  SizedBox(height: 32.0,),
                  _loadConfirmationState()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _loadConfirmationState() {
    return StreamBuilder<BaseResponse<GenericResponse>>(
        stream: bloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Success<GenericResponse>).getData().message),
                ));
              });
              bloc.hasReadData(result);
            }
          } else if (result is Error) {
            widget.loaderWidget.dismiss(context);
            if (!result.hasReadData) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  content: Text((result as Error).getError().message),
                ));
                bloc.hasReadData(result);
              });
            }
          } else if (result is Loading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              widget.loaderWidget.showLoaderDialog(context);
            });
          } else {}
          return SizedBox.shrink();
        });
  }


  void _showConfirmation2(String title) {
    //controller.text = value;
    GeneralBottomSheet.showSelectorBottomSheet(
        context,
        Column(
            children: [
              Text(
                title,
                style: Theme
                    .of(context)
                    .textTheme
                    .headline2
                    .copyWith(
                    fontSize: 20.0
                ),
              ),

              SizedBox(height: 8.0,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    "Select transactions for statement request",
                    textAlign: TextAlign.center,
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(
                        color: Color(0xFF6E88A9)
                    )
                ),
              ),
              SizedBox(height: 8.0,),
              StatefulBuilder(builder: (thisLowerContext, innerSetState) {
                  return Column(
                    children: [
                      CheckboxListTile(
                        checkColor: Colors.white,
                        value: isPaymentSelected,
                        title: Text("Payments"),
                        shape: CircleBorder(),
                        onChanged: (bool value) {
                          innerSetState(() {
                            isPaymentSelected = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        checkColor: Colors.white,
                        value: isRequestSelected,
                        title: Text("Requests"),
                        shape: CircleBorder(),
                        onChanged: (bool value) {
                          innerSetState(() {
                            isRequestSelected = value;
                          });
                        },
                      ),
                      CheckboxListTile(
                        checkColor: Colors.white,
                        value: isBillsSelected,
                        title: Text("Bills"),
                        shape: CircleBorder(),
                        onChanged: (bool value) {
                          innerSetState(() {
                            isBillsSelected = value;
                          });
                        },
                      ),
                    ],
                  );
               }),
              SizedBox(height: 24.0,),
              PrimaryButton(text: "Continue", pressListener: () async {
                // sendBloc.sendMoneyToAccount(
                //     pin,
                //     amountResult.amount,
                //     noteController.text,
                //     accountNumberController.text,
                //     beneficiaryName,
                //     bankCode
                // );

                Navigator.pop(context);
              }),
            ]
        ),
            () {

        });
  }


  _selectDate(BuildContext context, bool isStartDate) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context, isStartDate);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context, isStartDate);
    }
  }

  buildMaterialDatePicker(BuildContext context, bool isStartDate) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? selectedStartDate : selectedEndDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if (picked != null)
      isStartDate ? selectedStartDate = picked : selectedEndDate = picked;
    (isStartDate ? startDateController : endDateController).text =
    "${picked.toLocal()}".split(' ')[0];
  }

  buildCupertinoDatePicker(BuildContext context, bool isStartDate) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery
                .of(context)
                .copyWith()
                .size
                .height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                isStartDate ? selectedStartDate = picked : selectedEndDate =
                    picked;
                (isStartDate ? startDateController : endDateController).text =
                "${picked.toLocal()}".split(' ')[0];
              },
              initialDateTime: isStartDate
                  ? selectedStartDate
                  : selectedEndDate,
              minimumYear: 1930,
              maximumYear: 2030,
            ),
          );
        });
  }
}
