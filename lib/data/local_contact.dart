abstract class LocalContact{
  String getSearchableValue(){}
}

class PhoneContact implements LocalContact {
  String name, number;
  PhoneContact({this.name, this.number});

  @override
  String getSearchableValue() {
    return (this.name+this.number).toLowerCase();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['number'] = this.number;
    return data;
  }
}