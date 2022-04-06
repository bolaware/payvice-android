import 'dart:convert';
import 'dart:io';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:payvice_app/data/local_contact.dart';
import 'package:payvice_app/data/response/activities/actvities_response.dart';
import 'package:payvice_app/data/response/banks_list_response.dart';
import 'package:payvice_app/data/response/beneficiaries/bank_beneficiaries_response.dart';
import 'package:payvice_app/data/response/bills/bills_category_response.dart';
import 'package:payvice_app/data/response/bills/bills_product_response.dart';
import 'package:payvice_app/data/response/bills/mobile_number_resolve_response.dart';
import 'package:payvice_app/data/response/bills/recurring_bills_response.dart';
import 'package:payvice_app/data/response/contacts/contacts_response.dart';
import 'package:payvice_app/data/response/notification/notification_response.dart';
import 'package:payvice_app/data/response/notification/requests_response.dart';
import 'package:payvice_app/data/response/notification/treat_request_body.dart';
import 'package:payvice_app/data/response/onboarding/login_response.dart';
import 'package:payvice_app/data/response/onboarding/resend_otp_response.dart';
import 'package:payvice_app/data/response/onboarding/reset_password_request_response.dart';
import 'package:payvice_app/data/response/onboarding/signup_response.dart';
import 'package:payvice_app/data/response/send/account_resolve_response.dart';
import 'package:payvice_app/data/response/success_response.dart';
import 'package:payvice_app/data/response/verification/verification_initial_response.dart';
import 'package:payvice_app/data/response_base.dart';
import 'package:payvice_app/services/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:payvice_app/services/cache.dart';
import 'package:payvice_app/ui/screens/notification/notification_screen.dart';

class Network {

  Map<String, String> _header =
      {'content-type': 'application/json'};

  final cache = Cache();

  final deviceKey = "ODgzODM4Mzh8fFNhbXN1bmcgUzEwfHxhbmRyb2lkfHwxMHx8ODM4MzgzaGhkaGQ=";
  final baseUrl = "vas.itexpayvice.com";
  final loginEmailUrl = "/payvice/api/v1/customers/customer/login/with-email/";
  final loginPhoneUrl = "/payvice/api/v1/customers/customer/login/";
  final loginPinUrl = "/payvice/api/v1/customers/customer/login/with-pin/";
  final signUpUrl = "/payvice/api/v1/customers/customer/signup";
  final updateProfileUrl = "/payvice/api/v1/customers/customer/update-profile";
  final confirmOtpUrl = "/payvice/api/v1/customers/customer/signup/verify";
  final confirmBvnOtpUrl = "/payvice/api/v1/verification/bvn/complete";
  final resendOtpUrl = "/payvice/api/v1/customers/customer/otp/resend";
  final pinUrl = "/payvice/api/v1/customers/customer/set-pin";
  final contactsResolveUrl = "/payvice/api/v1/contact/resolve";
  final sendMoneyUrl = "/payvice/api/v1/money/send";
  final requestMoneyUrl = "/payvice/api/v1/money/request";
  final changePinUrl = "/payvice/api/v1/customers/customer/change-pin";
  final changePassUrl = "/payvice/api/v1/customers/customer/password/change";
  final requestStatementUrl = "payvice/api/v1/balance/statement";
  final bankAccountResolveUrl = "/payvice/api/v1/bank/resolve";
  final getBankBeneficiariesUrl = "/payvice/api/v1/beneficiary/all";
  final getActivitiesUrl = "/payvice/api/v1/activities/all";
  final getBanksUrl = "/payvice/api/v1/banks/all";
  final uploadSelfieUrl = "/payvice/api/v1/customers/customer/set-avatar";
  final createVerificationSessionUrl = "/payvice/api/v1/verification/session/create";
  final saveKycDetailsUrl = "/payvice/api/v1/verification/kyc-details/save";
  final resetPasswordRequestUrl = "/payvice/api/v1/customers/customer/password/reset";
  final resetPasswordConfirmUrl = "/payvice/api/v1/customers/customer/password/reset/complete";
  final getBillsCategoryUrl = "/payvice/api/v1/bills/categories";
  final getBillsProductUrl = "/payvice/api/v1/bills/category/CODE/products";
  final notificationUrl = "/payvice/api/v1/notifications/all";
  final getRequestUrl = "/payvice/api/v1/money/request/all";
  final payBillsUrl = "/payvice/api/v1/bills/pay";
  final airtimeSelfUrl = "/payvice/api/v1/airtime/buy/myself";
  final airtimeOthersUrl = "/payvice/api/v1/airtime/buy";
  final profileUrl = "/payvice/api/v1/customers/customer/profile";
  final verifyInitialUrl = "/payvice/api/v1/verification/bvn/initiate";
  final requestTreatUrl = "/payvice/api/v1/money/request/treat";
  final recurringBillUrl = "/payvice/api/v1/money/payments/recurring";
  final inviteFriendUrl = "/payvice/api/v1/customers/customer/invite-friends";

  Future<BaseResponse<LoginResponse>> loginWithEmail(
      String email, String password
  ) async {
    final body = {"email_address": email, "password": password};
    return _login(loginEmailUrl, body);
  }

  Future<BaseResponse<LoginResponse>> loginWithMobileNumber(String phoneNumber, String password) async {
    final body = {"mobile_number": phoneNumber, "password": password};
    return _login(loginPhoneUrl, body);
  }

  Future<BaseResponse<LoginResponse>> loginWithPin(String mobileNumber, String pin) async {
    final body = {"mobile_number": mobileNumber, "pin": pin};
    return _login(loginPinUrl, body);
  }

  Future<BaseResponse<LoginResponse>> _login(String url, Map body) async {

    await _setDeviceHeader();

    print("======================");
    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, url),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      await cache.saveCustomerData(response.body);
      print(response.body);
      return Success(LoginResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while logging in");
    }
  }

  Future<BaseResponse<LoginResponse>> getProfile() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, profileUrl),
        headers: _header
    );

    print("********************");
    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      await cache.saveCustomerData(response.body);
      return Success(LoginResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting profile");
    }
  }

  Future<BaseResponse<SignupResponse>> signUp(
      String mobileNumber,
      String emailAddress,
      String password) async {

    await _setDeviceHeader();

    final body = {
        "type": "fastsignup",
        "fast_signup": {
        "mobile_number": mobileNumber,
        "country_code": "NG",
        "email_address": emailAddress,
        "password": password
      }
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, signUpUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      var formattedResponse = SignupResponse.fromJson(json.decode(response.body));
      formattedResponse.setFormattedPhone(mobileNumber);
      print(formattedResponse);
      return Success(formattedResponse);
    } else {
      return _errorHandler(response, "An error occurred while signing up");
    }
  }

  Future<BaseResponse<LoginResponse>> otpConfirm(
      String otp,
      String otpPrefix,
      String mobileNumber
      ) async {

    await _setDeviceHeader();

    final body = {
      "mobile_number": mobileNumber,
      "otp_prefix": otpPrefix,
      "otp": otp
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, confirmOtpUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      await cache.saveCustomerData(response.body);
      return Success(LoginResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while confirming OTP");
    }
  }

  Future<BaseResponse<GenericResponse>> otpBvnConfirm(
      String otp,
      String otpPrefix
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "otp_prefix": otpPrefix,
      "otp": otp
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, confirmBvnOtpUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      await cache.saveCustomerData(response.body);
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while confirming OTP");
    }
  }

  Future<BaseResponse<bool>> createVerificationSession() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.post(
        Uri.https(baseUrl, createVerificationSessionUrl),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(true);
    } else {
      return _errorHandler(response, "An error occurred while verifying BVN");
    }
  }


  Future<BaseResponse<GenericResponse>> verify(
      String bvn, String dob, String meansOfId, String idNumber
  ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();


    final body = {
      "bvn": bvn,
      "date_of_birth": dob,
      "means_of_id": meansOfId,
      "id_number": idNumber
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, saveKycDetailsUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while verifying BVN");
    }
  }

  Future<BaseResponse<BvnVerificationInitialResponse>> setBvn(String bvn, String dob) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "bvn":bvn,
      "dob":dob
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, verifyInitialUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(BvnVerificationInitialResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while setting BVN");
    }
  }


  Future<BaseResponse<GenericResponse>> updateProfile(
      String fullName,
      String dob,
      String username,
      String referralCode) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "full_name": fullName,
      "date_of_birth": dob,
      "username": username,
      "referral_code": referralCode
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, updateProfileUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while uploading profile");
    }
  }

  Future<BaseResponse<ResetPasswordRequestResponse>> resetPasswordInitialRequest(
      String mobileNumber
      ) async {
    await _setDeviceHeader();

    final body = {
      "mobile_number": mobileNumber
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, resetPasswordRequestUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      final formattedResponse = ResetPasswordRequestResponse.fromJson(json.decode(response.body));
      formattedResponse.setFormattedPhone(mobileNumber);
      return Success(formattedResponse);
    } else {
      return _errorHandler(response, "An error occurred while resetting password");
    }
  }


  Future<BaseResponse<GenericResponse>> resetPasswordConfirmationRequest(
      String mobileNumber, String otpPrefix, String otp, String password
      ) async {
    await _setDeviceHeader();

    final body = {
      "mobile_number": mobileNumber,
      "otp_prefix": otpPrefix,
      "otp": otp,
      "password":password
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, resetPasswordConfirmUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while resetting password");
    }
  }

  Future<BaseResponse<ResendOtpResponse>> resendOtp(
      String previousOtpPrefix,
      String mobileNumber
      ) async {

    await _setDeviceHeader();

    final body = {
      "mobile_number": mobileNumber,
      "previous_otp_prefix": previousOtpPrefix
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, resendOtpUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(ResendOtpResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while resending otp");
    }
  }

  Future<BaseResponse<bool>> uploadSelfie(String imagePath) async {
    
    await _setDeviceHeader();
    await _setAuthorizationHeader();
    
    var request = new http.MultipartRequest("POST", Uri.https(baseUrl, uploadSelfieUrl));

    request.files.add(
        await http.MultipartFile.fromPath(
            'avatar', imagePath
        ));

    request.headers.addAll(_header);

    var response = await request.send();

    final res = await http.Response.fromStream(response);

    if (response.statusCode == 200) {
      print("========================success");
      return Success(true);
    } else {
      print("========================${res.body}");
      try {
        return Error(GenericResponse.fromJson(json.decode(res.body)));
      } catch(_){
        return Error(GenericResponse(status: "fail", statusCode: "0", message: "An error occurred while uploading selfie."));
      }
    }
  }

  Future<BaseResponse<GenericResponse>> setPin(String pin) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "pin": pin
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, pinUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      try {
        return Error(GenericResponse.fromJson(json.decode(response.body)));
      } catch(_){
        return Error(GenericResponse(status: "fail", statusCode: "0", message: "An error occurred while setting pin."));
      }
    }
  }


  Future<BaseResponse<GenericResponse>> treatRequest(TreatRequestBody body) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.post(
        Uri.https(baseUrl, requestTreatUrl),
        body: json.encode(body.toJson()),
        headers: _header
    );

    print("==================${json.encode(body.toJson())}");
    print("==================${response.body}");

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      try {
        return Error(GenericResponse.fromJson(json.decode(response.body)));
      } catch(_){
        return Error(GenericResponse(status: "fail", statusCode: "0", message: "An error occurred while setting pin."));
      }
    }
  }


  Future<BaseResponse<BankBeneficiaryResponse>> getBankBeneficiaries() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getBankBeneficiariesUrl),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      cache.saveBeneficiaries(response.body);
      return Success(BankBeneficiaryResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting beneficiaries");
    }
  }


  Future<BaseResponse<ActivitiesResponse>> getActivities() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getActivitiesUrl),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      cache.saveActivities(response.body);
      return Success(ActivitiesResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting activities");
    }
  }

  Future<BaseResponse<BanksListResponse>> getBanks() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getBanksUrl),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(BanksListResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting banks");
    }
  }

  Future<BaseResponse<SuccessResponse>> sendMoneyToAccount(
      String pin,
      String amount,
      String note,
      String accountNumber,
      String accountName,
      String bankCode
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "type": "account",
      "narration": note,
      "transaction_pin": pin,
      "amount": amount,
      "bank_account": {
        "account_number": accountNumber,
        "account_name": accountName,
        "bank_code": bankCode
      }
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, sendMoneyUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(SuccessResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while sending money to bank account");
    }
  }


  Future<BaseResponse<SuccessResponse>> sendMoneyToPayvice(
      String pin,
      String amount,
      String note,
      String phoneNumber,
      String name,
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "type":"payvice",
      "narration":note,
      "transaction_pin":pin,
      "amount":amount,
      "payvice":{
        "identifier":phoneNumber,
        "name":name
      }
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, sendMoneyUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(SuccessResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while sending money to payvice");
    }
  }

  Future<BaseResponse<GenericResponse>> changePin(String oldPin, String newPin) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();


    final body = {
      "new_pin": newPin,
      "pin": oldPin
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, changePinUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while changing pin");
    }
  }

  Future<BaseResponse<GenericResponse>> changePassword(String oldPass, String newPass) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();


    final body = {
      "old_password": oldPass,
      "new_password": newPass
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, changePassUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while changing password");
    }
  }

  Future<BaseResponse<GenericResponse>> requestMoneyFromPayvice(
      String amount,
      String note,
      String phoneNumber,
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "friend_identifier":phoneNumber,
      "amount":amount,
      "narration":note
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, requestMoneyUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while requesting money");
    }
  }

  Future<BaseResponse<GenericResponse>> requestStatement(
      String from,
      String to
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "from":from,
      "to":to
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, requestStatementUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while requesting statement");
    }
  }

  Future<BaseResponse<ContactsResponse>> getContacts(List<PhoneContact> contacts) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    var body = {
      "contacts": contacts.map((e) => e.number).toList()
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, contactsResolveUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(ContactsResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting contacts");
    }
  }


  Future<BaseResponse<BillsCategoryResponse>> getBillCategories() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getBillsCategoryUrl),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      print(response.body);
      cache.saveBillCategories(response.body);
      return Success(BillsCategoryResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting bills categories");
    }
  }

  Future<BaseResponse<BillsProductResponse>> getBillProducts(String billGroupCode) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getBillsProductUrl.replaceAll("CODE", billGroupCode)),
        headers: _header
    );

    print("hmmmmm");
    print("$baseUrl${getBillsProductUrl.replaceAll("CODE", billGroupCode)}");
    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(BillsProductResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting bills products");
    }
  }

  Future<BaseResponse<RecurringBillsResponse>> getRecurringBills() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, recurringBillUrl),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(RecurringBillsResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting recurring bills");
    }
  }

  Future<BaseResponse<GenericResponse>> actionOnRecurringBills(String id, String action) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.put(
        Uri.https(baseUrl, "/payvice/api/v1/money/payments/recurring/$id/$action"),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting performing actions on bills");
    }
  }

  Future<BaseResponse<LoginResponse>> actionOnPreferences(String preference, String value) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "value": value
    };

    http.Response response = await http.patch(
        Uri.https(baseUrl, "/payvice/api/v1/customers/profile/preference/$preference/set"),
        headers: _header,
        body: json.encode(body)
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return await getProfile();
    } else {
      return _errorHandler(response, "An error occurred while getting performing actions on bills");
    }
  }

  Future<BaseResponse<GenericResponse>> inviteFriends(String mobileNumber) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
        "identifier": mobileNumber
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, inviteFriendUrl),
        headers: _header,
        body: json.encode(body)
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(GenericResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting inviting this friend");
    }
  }

  Future<BaseResponse<RequestsResponse>> getRequests() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, getRequestUrl),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(RequestsResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while fetching requests");
    }
  }

  Future<BaseResponse<NotificationResponse>> getNotification() async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, notificationUrl),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(NotificationResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while getting bills products");
    }
  }

  Future<BaseResponse<MobileNumberResolveResponse>> resolveMobileNumber(String mobileNumber) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    http.Response response = await http.get(
        Uri.https(baseUrl, "/payvice/api/v1/bills/mobilenumber/$mobileNumber/validate"),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(MobileNumberResolveResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while resolving mobile number.");
    }
  }

  Future<BaseResponse<AccountResolveResponse>> resolveAccountNumber(
      String accountNumber,
      String bankCode
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "bank_code":bankCode,
      "account_number":accountNumber
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, bankAccountResolveUrl),
        body: json.encode(body),
        headers: _header
    );

    print(body);

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(AccountResolveResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while resolving bank accounts.");
    }
  }

  Future<BaseResponse<SuccessResponse>> payBills(
      String billerCode, String itemCode, String pin, String customerId
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "amount":"100",
      "item_code": itemCode,
      "biller_code": billerCode,
      "transaction_pin": pin,
      "beneficiary_detail":customerId
    };

    http.Response response = await http.post(
        Uri.https(baseUrl, payBillsUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(SuccessResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while paying bills.");
    }
  }

  Future<BaseResponse<SuccessResponse>> payAirtimeForMyself(
      String amount
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "amount":amount
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, airtimeSelfUrl),
        body: json.encode(body),
        headers: _header
    );

    print(response.body);

    if(response.statusCode == HttpStatus.ok){
      return Success(SuccessResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while buying airtime.");
    }
  }

  Future<BaseResponse<SuccessResponse>> payAirtimeForOthers(
      String amount, String pin, String number, int frequencyId
      ) async {

    await _setDeviceHeader();
    await _setAuthorizationHeader();

    final body = {
      "amount":amount,
      "transaction_pin":pin,
      "beneficiary_number": number,
      "recurring_type_id": frequencyId
    };

    print(body);

    http.Response response = await http.post(
        Uri.https(baseUrl, airtimeOthersUrl),
        body: json.encode(body),
        headers: _header
    );

    if(response.statusCode == HttpStatus.ok){
      return Success(SuccessResponse.fromJson(json.decode(response.body)));
    } else {
      return _errorHandler(response, "An error occurred while setting pin.");
    }
  }

  Future<Error<T>> _errorHandler<T>(http.Response response, String msg) async {
    try {
      final errorResponse = GenericResponse.fromJson(json.decode(response.body));
      if(response.statusCode == HttpStatus.unauthorized) {
        print("********************");
        print(response.body);
        print(response.request.url);
        cache.nuke();
        FBroadcast.instance().broadcast("logout", value: true);
      }
      return Error(errorResponse);
    } catch(e){
      return Error(GenericResponse(status: "fail", statusCode: "0", message: "$e----->${response.body}"));
    }
  }

  Future<void> _setAuthorizationHeader() async {
    var token = await cache.getToken();

    _header.addAll({"Authorization":"Bearer $token"});
  }

  Future<void> _setDeviceHeader() async {
    var deviceInfo = await DeviceInfo().getDeviceInfo();
    var firebaseToken = await cache.getFirebaseTokenKey();

    _header.addAll({"device":deviceInfo, "push_token": firebaseToken});

    print(_header);
  }

}