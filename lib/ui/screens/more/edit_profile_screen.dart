import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/onboarding/selfie_bloc.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/ui/customs/general_bottom_sheet.dart';
import 'package:payvice_app/ui/customs/loader_widget.dart';
import 'package:payvice_app/ui/customs/primary_button.dart';
import 'package:payvice_app/ui/customs/single_input_field.dart';

class EditProfileScreen extends StatefulWidget {

  final loaderWidget = LoaderWidget();

  EditProfileScreen({Key key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final nameController = TextEditingController();
  final dobController = TextEditingController();

  final selfieBloc = SelfieBloc();
  DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: selfieBloc,
      child: Scaffold(
        appBar: AppBar(
            elevation: 0,
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            title: Text(
              "Profile",
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
        body: StreamBuilder<BaseResponse<LoginResponse>>(
          stream: profileBloc.stream,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result is Success) {
              final userData = (snapshot.data as Success<LoginResponse>).getData().customer;
              selectedDate = userData.getDateInstance();
              return Padding(
                padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildEditProfileContainer(profileBloc),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset("images/tap_icon.svg"),
                          SizedBox(width: 4.0,),
                          Text("Tap avatar to update profile picture", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9), fontSize: 12.0),),
                        ],
                      ),
                      SizedBox(height: 16.0,),
                      GestureDetector(
                          onTap: () {
                            //_showConfirmation("Full Name", "${userData.firstName} ${userData.lastName}", nameController);
                          },
                          child: _buildProfileRow(context, "Full Name", "${userData.firstName} ${userData.lastName}")),
                      SizedBox(height: 12.0,),
                      GestureDetector(
                          onTap: () {
                            //_showConfirmation("Date of Birth", userData.getFormattedDOB(), dobController);
                          },
                          child: _buildProfileRow(context, "Date of Birth", userData.getFormattedDOB())
                      ),
                      SizedBox(height: 12.0,),
                      _buildProfileRow(context, "Username", userData.mobileNumber),
                      SizedBox(height: 12.0,),
                      Visibility(
                        visible: false,
                        child: GestureDetector(
                          child: _buildProfileRow(context, "Gender", "N/A"),
                          onTap: () {
                            _showConfirmation2("Gender", "Male");
                          },
                        ),
                      ),
                      SizedBox(height: 12.0,),
                      _buildUploadSelfieStream(profileBloc),
                    ],
                  ),
                ),
              );
            }
            return SizedBox.shrink();
          }
        ),
      ),
    );
  }

  StreamBuilder<BaseResponse<LoginResponse>> _buildUploadSelfieStream(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
                    stream: selfieBloc.stream,
                    builder: (context, snapshot) {
                      final result = snapshot.data;
                      if (result is Success) {
                        if (!result.hasReadData) {
                          widget.loaderWidget.dismiss(context);
                          profileBloc.setProfile(result);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text("Profile picture upload successful"),
                            ));
                            selfieBloc.hasReadData(result);
                          });
                        }
                      } else if(snapshot.data is Loading) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          widget.loaderWidget.showLoaderDialog(context);
                        });
                      } else if(snapshot.data is Error) {
                        if (!result.hasReadData) {
                          widget.loaderWidget.dismiss(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              behavior: SnackBarBehavior.floating,
                              content: Text((result as Error).getError().message),
                            ));
                            selfieBloc.hasReadData(result);
                          });
                        }
                      } else {  }
                      return SizedBox(height: 12.0,);
                    }
                  );
  }

  void _showConfirmation(String title, String value, TextEditingController controller) {
    controller.text = value;
    GeneralBottomSheet.showSelectorBottomSheet (
        context,
        Column(
            children: [
              Text(
                "Change $title",
                style: Theme.of(context).textTheme.headline2.copyWith(
                    fontSize: 20.0
                ),
              ),
              SizedBox(height: 16.0,),
              ClickableContainer(
                child: SingleInputFieldWidget(
                  hint: title,
                  controller: controller,
                  isLastField: true,
                ),
                isClickable: !title.contains("Date of Birth"),
                tapListener: () {
                  _selectDate(context);
                },
              ),
              Visibility(
                visible: title.contains("Name"),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).primaryColor,
                        size: 16.0,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text("Kindly use legal official name", style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.0,),
              PrimaryButton(text: "Continue", pressListener: () async {

                Navigator.pop(context);
              }),
            ]
        ),
            (){

        });
  }

  void _showConfirmation2(String title, String value) {
    //controller.text = value;
    GeneralBottomSheet.showSelectorBottomSheet (
        context,
        Column(
            children: [
              Text(
                "Change $title",
                style: Theme.of(context).textTheme.headline2.copyWith(
                    fontSize: 20.0
                ),
              ),
              SizedBox(height: 16.0,),
              RadioButtonGroup(
                  labels: <String>[
                    "Male",
                    "Female",
                  ],
                  onSelected: (String selected) => print(selected)
              ),
              Visibility(
                visible: title.contains("Name"),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info,
                        color: Theme.of(context).primaryColor,
                        size: 16.0,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Text("Kindly use legal official name", style: TextStyle(color: Colors.grey),),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.0,),
              PrimaryButton(text: "Continue", pressListener: () async {

                Navigator.pop(context);
              }),
            ]
        ),
            (){

        });
  }

  Widget _buildEditProfileContainer(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            final customer = (snapshot.data as Success<LoginResponse>).getData().customer;
            return Container(
              padding: EdgeInsets.all(16.0),
              margin:
              const EdgeInsets.symmetric(vertical: 24.0, horizontal: 5.0),
              width: double.infinity,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: Colors.greenAccent.withAlpha(20)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: ()=> showImagePickerDialog(),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor:
                          Theme.of(context).primaryColor.withAlpha(30),
                          foregroundImage: NetworkImage(customer.getAvatar()),
                          child: SvgPicture.asset(
                              "images/multi_coloured_person.svg"),
                        ),
                        Positioned(
                          top: 0.0,
                          right: 0.0,
                          child: new InkWell(
                              child: Container(
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).primaryColor),
                                  child: Icon(
                                    Icons.check,
                                    size: 16.0,
                                    color: Colors.white,
                                  )),
                              onTap: () {}),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "${customer.firstName} ${customer.lastName}",
                            style: Theme.of(context)
                                .textTheme
                                .headline3
                                .copyWith(fontSize: 24.0),
                          ),
                          Text(
                            "${customer.mobileNumber}",
                            style: TextStyle(color: Colors.black54),
                          ),
                          SizedBox(
                            height: 12.0,
                          ),
                        ],
                      ))
                ],
              ),
            );
          }
          return SizedBox.shrink();
        }
    );
  }


  Future<void> showImagePickerDialog() {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        final ImagePicker _picker = ImagePicker();
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Upload profile picture", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black)),
              SizedBox(height: 8.0,),
              InkWell(
                onTap: () async {
                  final XFile image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 25);
                  selfieBloc.uploadSelfie(image.path);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("From Gallery", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey)),
                ),
              ),
              SizedBox(height: 12.0,),
              InkWell(
                onTap: () async {
                  final XFile image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 25);
                  selfieBloc.uploadSelfie(image.path);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("From Camera", style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Material _buildProfileRow(BuildContext context, String title, String value) {
    return Material(
      elevation: 2,
      color: Colors.white,
      shadowColor: Theme.of(context).primaryColor.withAlpha(50),
      borderRadius: BorderRadius.all(Radius.circular(4)),
      child: Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Color(0xFF6E88A9)),)),
              Expanded(child: Text(value, textAlign: TextAlign.end, style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.black),)),
            ],
          )
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final ThemeData theme = Theme.of(context);
    assert(theme.platform != null);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return buildMaterialDatePicker(context);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return buildCupertinoDatePicker(context);
    }
  }

  buildMaterialDatePicker(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1930),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child,
        );
      },
    );
    if(picked != null) selectedDate = picked;
    dobController.text = "${picked.toLocal()}".split(' ')[0];
  }

  buildCupertinoDatePicker(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (picked) {
                selectedDate = picked;
                dobController.text = "${picked.toLocal()}".split(' ')[0];
              },
              initialDateTime: selectedDate,
              minimumYear: 1930,
              maximumYear: 2030,
            ),
          );
        });
  }
}
