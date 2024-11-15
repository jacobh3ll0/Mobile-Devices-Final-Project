// class to store the user options and interact with the database
class UserOptions {
  UserOptions({this.id, required this.option, required this.value});

  late String option;
  late String value;
  late int? id;

  UserOptions.fromMap(Map<String, dynamic> map) {
    id = map['id']!;
    option = map['option']!;
    value = map['value']!;
  }

  // Converts the instance into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'option': option,
      'value': value,
    };
  }

  @override
  String toString() {
    return "id: $id, [$option : $value]";
  }
}