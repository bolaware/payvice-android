
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  String removeFirstZeroInPhoneNumber(String countryCode) {
    if(this.startsWith("0")) {
      return this.replaceFirst("0", countryCode);
    } else {
      return this;
    }
  }
}
