
class Validators {
    static String isEmailValid(String email) {
      bool isEmailValid = RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+"
      ).hasMatch(email);
      if (isEmailValid) return null;
      return "Email is not valid";
    }

    static String isPhoneValid(String phone, String code) {
      bool isPhoneValid = RegExp(
      r'^\+[1-9]{1}[0-9]{6,14}'
      ).hasMatch(code + phone);
      if (isPhoneValid) return null;
      return "Phone number is not valid";
    }

    static String isEmptyValid(String value) {
      bool isValid = value.isNotEmpty && value != null;
      if (isValid) return null;
      return "Cannot not be empty";
    }

    static String similarityValid(String thisValue, String compareValue) {
      bool isValid = thisValue == compareValue;
      if (isValid) return null;
      return "Confirm password doesn't match";
    }

    static String isPasswordValid(String password) {
      // r'^
      //   (?=.*[A-Z])       // should contain at least one upper case
      //   (?=.*[a-z])       // should contain at least one lower case
      //   (?=.*?[0-9])      // should contain at least one digit
      //   (?=.*?[!@#\$&*~]) // should contain at least one Special character
      //     .{8,}             // Must be at least 8 characters in length
      // $
      // bool isPasswordValid = RegExp(
      //     r'^(?=.*?[A-Z])' // should contain at least one upper case
      //     r'(?=.*?[a-z])'   // should contain at least one lower case
      //     r'(?=.*?[0-9])'   // should contain at least one digit
      //     r'(?=.*?[!@#\$&*~])'  // should contain at least one Special character
      //     r'.{8,}$'  // Must be at least 8 characters in length
      // ).hasMatch(password);
      bool isPasswordValid = RegExp(
          r'.{6,}$'
      ).hasMatch(password);
      if (isPasswordValid) return null;
      //return "A minimum of eight characters, at least an upper case, a lower case, a number and a special character";
      //return "A minimum of six characters needed";
    }

    static PasswordValidatorCheck isPasswordValidCheck(String password) {
      return PasswordValidatorCheck(
          isUpperCase : isRegexMatched(password, '(?=.*?[A-Z])'),
          isLowerCase : isRegexMatched(password, '(?=.*?[a-z])'),
          isANumber : isRegexMatched(password, '(?=.*?[0-9])'),
          isSpecialChar : isRegexMatched(password, '[^A-Za-z0-9]'),
      );
    }

    static bool isRegexMatched(String value, String regex){
      return RegExp(
          regex
      ).hasMatch(value);
    }

    static String isNameValid(String name) {
      bool isNameValid = name.split(" ").length >= 2;
      if (isNameValid) return null;
      return "Name is not valid";
    }

    static String isAddressValid(String address) {
      bool isAddressValid = address.length > 7;
      if (isAddressValid) return null;
      return "Address is not valid";
    }


    static String isBvnValid(String bvn) {
      bool isAddressValid = bvn.length == 11;
      if (isAddressValid) return null;
      return "BVN is not valid";
    }

    static String isAccountNumberValid(String account) {
      bool isAccountNumberValid = account.length == 10;
      if (isAccountNumberValid) return null;
      return "Account number is not valid";
    }
}


class PasswordValidatorCheck {
  bool isUpperCase = false;
  bool isLowerCase = false;
  bool isANumber = false;
  bool isSpecialChar = false;

  PasswordValidatorCheck({
    this.isUpperCase,
    this.isLowerCase,
    this.isANumber,
    this.isSpecialChar,
  });

  bool isAllPassed() {
    return isUpperCase && isLowerCase && isANumber && isSpecialChar;
  }

  String getErrorMessage() {
    return isAllPassed() ? null : "A minimum of eight characters, at least an upper case, a lower case, a number and a special character";
  }
}