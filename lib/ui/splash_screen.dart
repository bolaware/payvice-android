import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/bloc/profile/get_profile_cache_bloc.dart';
import 'package:payvice_app/bloc/profile/identifier_bloc.dart';
import 'package:payvice_app/data/identifier.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final profileCacheBloc = GetCacheProfileBloc();
  final identifierBloc = IdentifierBloc();

  @override
  void initState() {
    profileCacheBloc.getProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final profileBloc = BlocProvider.of<GetMemoryProfileBloc>(context);
    return BlocProvider(
      bloc: identifierBloc,
      child: Scaffold(
        body: Container(
          color: Theme.of(context).primaryColorDark,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: SvgPicture.asset('images/payvice_onboarding.svg'),
                  ),
                ),
                Expanded(
                  child: SvgPicture.asset('images/payvice_mask_onboarding.svg'),
                ),
                _checkCachedData(profileBloc),
                _checkedIdentifierData()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _checkCachedData(GetMemoryProfileBloc profileBloc) {
    return StreamBuilder<BaseResponse<LoginResponse>>(
        stream: profileCacheBloc.stream,
        builder: (context, snapshot) {
          Future.delayed(Duration(seconds: 4), () async {
            if(snapshot.data is Success) {
              //profileBloc.setProfile(snapshot.data);
              //Navigator.popAndPushNamed(context, PayviceRouter.home);
              identifierBloc.getIdentifier();
            } else if(snapshot.data is Error){
              identifierBloc.getIdentifier();
            }
          });
          return SizedBox.shrink();
        }
    );
  }

  Widget _checkedIdentifierData() {
    return StreamBuilder<BaseResponse<Identifier>>(
        stream: identifierBloc.stream,
        builder: (context, snapshot) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if(snapshot.data is Success) {
            Navigator.popAndPushNamed(context, PayviceRouter.pin_login_screen, arguments: (snapshot.data as Success<Identifier>).getData());
          } else if(snapshot.data is Error){
            Navigator.popAndPushNamed(context, PayviceRouter.intro);
          }
        });
          return SizedBox.shrink();
        }
    );
  }
}
