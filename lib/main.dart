import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:payvice_app/bloc/bloc_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:payvice_app/bloc/onboarding/local_auth.dart';
import 'package:payvice_app/bloc/profile/get_memory_profile_bloc.dart';
import 'package:payvice_app/ui/home_container_screen.dart';
import 'package:payvice_app/routes/routes.dart';
import 'package:payvice_app/services/device_info.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:payvice_app/ui/screens/send/send_options_screen.dart';
import 'package:payvice_app/ui/splash_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/create_pin_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/reset_password_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_in_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_up_comeplete_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_up_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MainScreen());
  configLoading();
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ripple
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..dismissOnTap = false
    ..userInteractions = false;
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  final primaryColor = Color(0xFF0084FF);

  final primaryDarkColor = Color(0xFF083061);

  final primaryLightColor = Color(0XFF67B6FF);

  final accentColor = Color(0XFF67B6FF);

  final profileBloc = GetMemoryProfileBloc();


  @override
  void initState() {
    _setupCrashlytics();
    DeviceInfo().setDeviceInfo();
    super.initState();
  }

  Future<void> _setupCrashlytics() async {
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    Function originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      print("Error loading firebase");
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      originalOnError(errorDetails);
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GetMemoryProfileBloc>(
      bloc: profileBloc,
      child: OverlaySupport(
        child: MaterialApp(
          theme: ThemeData(
            fontFamily: 'NeurialGrotesk',
            primaryColor: primaryColor,
            primaryColorLight: primaryLightColor,
            primaryColorDark: primaryDarkColor,
            accentColor: accentColor,
            bottomSheetTheme: BottomSheetThemeData(
                backgroundColor: Colors.lightBlue.withAlpha(160),),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  primary: primaryColor,
                )
            ),
            textTheme: TextTheme(
              headline2: TextStyle(
                color: primaryDarkColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              headline3: TextStyle(
                color: Colors.black,
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
              ),
              bodyText1: TextStyle(
                color: primaryLightColor,
                fontSize: 16.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          builder: EasyLoading.init(),
          initialRoute: PayviceRouter.splash,
          onGenerateRoute: PayviceRouter.generateRoute,
          // home: Scaffold(
          //    body: PayviceFriendsScreen(),
          //  ),
        ),
      ),
    );
  }
}

