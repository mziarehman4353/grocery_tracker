import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/grocery_item.dart';

class GroceryService {
  static const String _storageKey = 'grocery_items';

  Future<void> saveItems(List<GroceryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedItems =
        items.map((item) => jsonEncode(item.toMap())).toList();
    await prefs.setStringList(_storageKey, encodedItems);
  }

  Future<List<GroceryItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList(_storageKey);
    if (savedList == null) return [];

    return savedList
        .map((item) => GroceryItem.fromMap(jsonDecode(item)))
        .toList();
  }
}
