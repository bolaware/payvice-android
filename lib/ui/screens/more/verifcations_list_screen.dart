import 'package:flutter/material.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/ui/customs/form_container.dart';
import 'package:payvice_app/ui/customs/leading_text_widget.dart';

class VerificationListScreen extends StatefulWidget {
  const VerificationListScreen({Key key}) : super(key: key);

  @override
  _VerificationListScreenState createState() => _VerificationListScreenState();
}

class _VerificationListScreenState extends State<VerificationListScreen> {
  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileBloc.stream,
        builder: (context, snapshot) {
          final result = snapshot.data;
          if (result is Success) {
            final loginResponse =
                (snapshot.data as Success<LoginResponse>).getData();
            final isVerified =
                loginResponse.verification.bvnVerificationStatus == "Verified";

            return Scaffold(
              appBar: AppBar(
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    "Verification",
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
              body: Container(
                child: FormContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "${isVerified ? "No" : "1"} pending verification",
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1
                                .copyWith(color: Color(0xFF6E88A9))),
                      ),
                      SizedBox(
                        height: 24.0,
                      ),
                      verificationCard("Phone number", loginResponse.customer.mobileNumber, false),
                      SizedBox(
                        height: 14.0,
                      ),
                      verificationCard("Bank Verification Number", "${isVerified ? loginResponse.verification.bvn : "No BVN yet"}",
                          !isVerified),
                      SizedBox(
                        height: 14.0,
                      ),
                      verificationCard(
                          "Email address", loginResponse.customer.emailAddress, false),
                      SizedBox(
                        height: 32.0,
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return SizedBox.shrink();
          }
        });
  }

  Widget verificationCard(String title, String value, bool isPending) {
    return Container(
      margin: EdgeInsets.all(2.0),
      child: Material(
        elevation: 4,
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(6)),
        child: InkWell(
          onTap: () {
            if(isPending && title == "Bank Verification Number") {
              Navigator.pushNamed(
                  context,
                  PayviceRouter.bvn_verification_initial
              );
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: LeadingText(
                    icon: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText1.copyWith(
                          fontSize: 14.0,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold),
                    ),
                    textWidget: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontSize: 12.0, color: Colors.grey),
                    ),
                    isHorizontal: false,
                    spacing: 12.0,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                LeadingText(
                  icon: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        color: isPending
                            ? Colors.red.shade600
                            : Colors.green.shade700),
                    child: Row(
                      children: [
                        Visibility(
                            visible: !isPending,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Icon(
                                Icons.check,
                                size: 12.0,
                                color: Colors.white,
                              ),
                            )),
                        Text(
                          isPending ? "PENDING" : "VERIFIED",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyText2.copyWith(
                                fontSize: 12.0,
                                color: Colors.white,
                              ),
                        ),
                      ],
                    ),
                  ),
                  textWidget: Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0,
                  ),
                  isHorizontal: true,
                  spacing: 12.0,
                  crossAxisAlignment: CrossAxisAlignment.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
