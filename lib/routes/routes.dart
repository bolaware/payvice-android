
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:payvice_app/ui/home_container_screen.dart';
import 'package:payvice_app/ui/screens/airtime/airtime_and_data_screen.dart';
import 'package:payvice_app/ui/screens/airtime/airtime_others_screen.dart';
import 'package:payvice_app/ui/screens/airtime/airtime_screen.dart';
import 'package:payvice_app/ui/screens/bills/bills_payment_screen.dart';
import 'package:payvice_app/ui/screens/bills/recurring_bills_details_screen.dart';
import 'package:payvice_app/ui/screens/bills/recurring_bills_screen.dart';
import 'package:payvice_app/ui/screens/bvn_verification_complete_screen.dart';
import 'package:payvice_app/ui/screens/bvn_verification_initial_screen.dart';
import 'package:payvice_app/ui/screens/coming_soon/coming_soon_screen.dart';
import 'package:payvice_app/ui/screens/friends/friends_screen.dart';
import 'package:payvice_app/ui/screens/funding/bank_transfer_funding_screen.dart';
import 'package:payvice_app/ui/screens/funding/funding_options_screen.dart';
import 'package:payvice_app/ui/screens/general_container_screen.dart';
import 'package:payvice_app/ui/screens/more/change_password_screen.dart';
import 'package:payvice_app/ui/screens/more/edit_profile_screen.dart';
import 'package:payvice_app/ui/screens/more/more_screen.dart';
import 'package:payvice_app/ui/screens/more/notification_settings_screen.dart';
import 'package:payvice_app/ui/screens/more/referral_claim_reward_screen.dart';
import 'package:payvice_app/ui/screens/more/referrals_settings_screen.dart';
import 'package:payvice_app/ui/screens/more/request_statement_screen.dart';
import 'package:payvice_app/ui/screens/more/verifcations_list_screen.dart';
import 'package:payvice_app/ui/screens/notification/notification_details_screen.dart';
import 'package:payvice_app/ui/screens/notification/notification_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/pin_login_screen.dart';
import 'package:payvice_app/ui/screens/pin/enter_pin_screen.dart';
import 'package:payvice_app/ui/screens/pin/enter_pin_screen2.dart';
import 'package:payvice_app/ui/screens/send/bank_beneficiary_screen.dart';
import 'package:payvice_app/ui/screens/send/payvice_friends_screen.dart';
import 'package:payvice_app/ui/screens/send/amount_screen.dart';
import 'package:payvice_app/ui/screens/send/send_money_to_bank_screen.dart';
import 'package:payvice_app/ui/screens/send/send_options_screen.dart';
import 'package:payvice_app/ui/screens/send/transaction_receipt.dart';
import 'package:payvice_app/ui/splash_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/create_pin_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/onboarding_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/reset_password_complete_complete_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/reset_password_confirmation_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/reset_password_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_in_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_up_comeplete_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/sign_up_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/verification_code_screen.dart';
import 'package:payvice_app/ui/screens/onboarding/welcome_screen.dart';

class PayviceRouter {
  static const String splash = '/';
  static const String intro = '/intro';
  static const String sign_in = '/sign-in';
  static const String sign_up = '/sign-up';
  static const String sign_up_complete = '/sign-up-complete';
  static const String reset_password = '/reset-password';
  static const String funding_options_screen = "/funding_options_screen";
  static const String bank_transfer_funding_screen = "/bank_transfer_funding_screen";
  static const String verification_code = '/verification_code';
  static const String bvn_verification_initial = '/bvn_verification_initial';
  static const String verification_list_page = "/verification_list_page";
  static const String bvn_verification_complete = '/bvn_verification_complete';
  static const String welcome_screen = '/welcome_screen';
  static const String edit_profile_screen = '/edit_profile_screen';
  static const String change_password_screen = '/change_password_screen';
  static const String create_pin = '/create_pin';
  static const String notification_screen = '/notification_screen';
  static const String reset_password_confirm = '/reset-password-confirm';
  static const String reset_password_confirm_confirm = '/reset-password-confirm-confirm';

  static const String home = '/home';
  static const String send_options_screen = '/send_options_screen';
  static const String send_to_bank = '/send_to_bank';
  static const String bank_beneficiary_screen = '/bank_beneficiary_screen';
  static const String payvice_friends = '/payvice_friends';
  static const String airtime_others_screen = '/airtime_others_screen';
  static const String send_amount_screen = '/send_amount_screen';
  static const String enter_pin_screen = '/enter_pin_screen';
  static const String referral_settings_screen = "/referral_settings_screen";
  static const String referral_claim_settings_screen = "/referral_claim_settings_screen";
  static const String request_statement_screen = '/request_statement_screen';
  static const String notification_setting_screen = '/notification_setting_screen';
  static const String transaction_receipt = '/transaction_receipt';
  static const String bill_payment_screen = '/bill_payment_screen';
  static const String airtime_screen = '/airtime';
  static const String airtime_data_screen = '/airtime_data_screen';
  static const String pin_login_screen = '/pin_login_screen';
  static const String general_container_screen = '/general_container_screen';
  static const String coming_soon_screen = '/coming_soon_screen';
  static const String recurring_bills_screen = '/recurring_bills_screen';
  static const String recurring_bills_details_screen = "/recurring_bills_details_screen";
  static const String request_details_screen = "/request_details_screen";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PayviceRouter.splash:
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case PayviceRouter.intro:
        return MaterialPageRoute(
          builder: (_) => OnboardingScreen(),
        );
      case PayviceRouter.sign_in:
        return MaterialPageRoute(
          builder: (_) => SignInScreen(),
        );
      case PayviceRouter.sign_up:
        return MaterialPageRoute(
          builder: (_) => SignUpScreen(),
        );
      case PayviceRouter.coming_soon_screen:
        return MaterialPageRoute(
          builder: (_) => ComingSoonScreen(),
        );
      case PayviceRouter.sign_up_complete:
        return MaterialPageRoute(
          builder: (_) => SignUpCompleteScreen(),
        );
      case PayviceRouter.recurring_bills_screen:
        return MaterialPageRoute(
          builder: (_) => RecurringBillsScreen(),
        );
      case PayviceRouter.recurring_bills_details_screen:
        return MaterialPageRoute(
          builder: (_) => RecurringBillsDetailsScreen(data: settings.arguments),
        );
      case PayviceRouter.request_details_screen:
        return MaterialPageRoute(
          builder: (_) => NotificationDetailsScreen(data: settings.arguments),
        );
      case PayviceRouter.pin_login_screen:
        return MaterialPageRoute(
          builder: (_) => PinLoginScreen(identifier: settings.arguments,),
        );
      case PayviceRouter.reset_password:
        return MaterialPageRoute(
          builder: (_) => ResetPasswordScreen(),
        );
      case PayviceRouter.funding_options_screen:
        return MaterialPageRoute(
          builder: (_) => FundingOptionScreen(),
        );
      case PayviceRouter.bank_transfer_funding_screen:
        return MaterialPageRoute(
          builder: (_) => BankTransferFundingScreen(),
        );
      case PayviceRouter.request_statement_screen:
        return MaterialPageRoute(
          builder: (_) => RequestStatementScreen(),
        );
      case PayviceRouter.notification_setting_screen:
        return MaterialPageRoute(
          builder: (_) => NotificationSettingScreen(),
        );
      case PayviceRouter.verification_code:
        return MaterialPageRoute(
          builder: (_) => VerificationCodeScreen(argument: settings.arguments),
        );
      case PayviceRouter.general_container_screen:
        return MaterialPageRoute(
          builder: (_) => GeneralContainerScreen(arg: settings.arguments),
        );
      case PayviceRouter.welcome_screen:
        return MaterialPageRoute(
          builder: (_) => WelcomeScreen(),
        );
      case PayviceRouter.create_pin:
        return MaterialPageRoute(
          builder: (_) => CreatePinScreen(argument: settings.arguments),
        );
      case PayviceRouter.reset_password_confirm:
          return MaterialPageRoute(
            builder: (_) => ResetPasswordConfirmationScreen(argument: settings.arguments),
          );
      case PayviceRouter.reset_password_confirm_confirm:
        return MaterialPageRoute(
          builder: (_) => ResetPasswordCompleteCompleteScreen(arguments: settings.arguments),
        );
      case PayviceRouter.home:
        return MaterialPageRoute(
          builder: (_) => HomeContainerScreen(),
        );
      case PayviceRouter.referral_settings_screen:
        return MaterialPageRoute(
          builder: (_) => ReferralSettingsScreen(),
        );
      case PayviceRouter.referral_claim_settings_screen:
        return MaterialPageRoute(
          builder: (_) => ReferralClaimRewardScreen(),
        );
      case PayviceRouter.payvice_friends:
        return MaterialPageRoute(
          builder: (_) => PayviceFriendsScreen(
              argument: settings.arguments ?? PayviceFriendsScreenArgument()
          ),
        );
      case PayviceRouter.airtime_screen:
        return MaterialPageRoute(
          builder: (_) => AirtimeScreen(),
        );
      case PayviceRouter.airtime_data_screen:
        return MaterialPageRoute(
          builder: (_) => AirtimeAndDataScreen(),
        );
      case PayviceRouter.send_options_screen:
        return MaterialPageRoute(
          builder: (_) => SendOptionsScreen(),
        );
      case PayviceRouter.send_amount_screen:
        return MaterialPageRoute(
          builder: (_) => AmountScreen(argument: settings.arguments),
        );
      case PayviceRouter.airtime_others_screen:
        return MaterialPageRoute(
          builder: (_) => AirtimeOthersScreen(),
        );
      case PayviceRouter.enter_pin_screen:
        return MaterialPageRoute(
          builder: (_) => EnterPin2Screen(isForSettingFingerPrint: settings.arguments ?? EnterPinScreenType.validate_transaction,),
        );
      case PayviceRouter.transaction_receipt:
        return MaterialPageRoute(
          builder: (_) => TransactionReceipt(
              argument: settings.arguments ?? ReceiptArgument.createDummy()
          )
        );
      case PayviceRouter.send_to_bank:
        return MaterialPageRoute(
          builder: (_) => SendMoneyToBankScreen(alreadySelectedBeneficiary: settings.arguments,),
        );
      case PayviceRouter.bank_beneficiary_screen:
        return MaterialPageRoute(
          builder: (_) => BankBeneficiaryScreen(beneficiaries: settings.arguments),
        );
      case PayviceRouter.bill_payment_screen:
        return MaterialPageRoute(
          builder: (_) => BillsPaymentScreen(argument: settings.arguments),
        );
      case PayviceRouter.notification_screen:
        return MaterialPageRoute(
          builder: (_) => NotificationScreen(),
        );


      case PayviceRouter.verification_list_page:
        return MaterialPageRoute(
          builder: (_) => VerificationListScreen(),
        );
      case PayviceRouter.bvn_verification_initial:
        return MaterialPageRoute(
          builder: (_) => BvnVerificationInitialScreen(),
        );
      case PayviceRouter.change_password_screen:
        return MaterialPageRoute(
          builder: (_) => ChangePasswordScreen(),
        );
      case PayviceRouter.edit_profile_screen:
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(),
        );
      case PayviceRouter.bvn_verification_complete:
        return MaterialPageRoute(
          builder: (_) => BvnVerificationCompleteScreen(argument: settings.arguments),
        );
      default:
        throw Error();
    }
  }
}
