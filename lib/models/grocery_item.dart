class GroceryItem {
  final String name;
  final String price;
  final String? desc;
  final DateTime date;
  final String? receiptPath;

  GroceryItem({
    required this.name,
    required this.price,
    required this.date,
    this.desc,
    this.receiptPath,
  });

  factory GroceryItem.fromMap(Map<String, dynamic> map) {
    return GroceryItem(
      name: map['name'],
      price: map['price'],
      desc: map['desc'],
      date: DateTime.parse(map['date']),
      receiptPath: map['receiptPath'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'desc': desc,
      'date': date.toIso8601String(),
      'receiptPath': receiptPath,
    };
  }
}
