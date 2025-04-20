import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const GroceryHomePage(),
    );
  }
}

class GroceryHomePage extends StatefulWidget {
  const GroceryHomePage({super.key});

  @override
  State<GroceryHomePage> createState() => _GroceryHomePageState();
}

class _GroceryHomePageState extends State<GroceryHomePage> {
  final List<Map<String, dynamic>> _items = [];
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDateTime;
  File? _receiptImage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  void _addItem() async {
    final name = _itemController.text.trim();
    final price = _priceController.text.trim();
    final desc = _descriptionController.text.trim();
    final now = _selectedDateTime ?? DateTime.now();

    if (name.isEmpty || price.isEmpty) return;

    setState(() {
      _items.add({
        'name': name,
        'price': price,
        'date': now.toString(),
        'desc': desc,
        'receiptPath': _receiptImage?.path,
      });

      _itemController.clear();
      _priceController.clear();
      _descriptionController.clear();
      _receiptImage = null;
      _selectedDateTime = null;
    });

    _saveData();
  }

  void _removeItem(int index) async {
    setState(() {
      _items.removeAt(index);
    });
    _saveData();
  }

  Future<void> _uploadReceipt() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> encodedItems = _items.map((item) => jsonEncode(item)).toList();
    prefs.setStringList('grocery_items', encodedItems);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedList = prefs.getStringList('grocery_items');
    if (savedList != null) {
      setState(() {
        _items.clear();
        _items.addAll(savedList.map((e) => jsonDecode(e)));
      });
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: _items.map((item) {
            return pw.Text(
              '${item['name']} - \$${item['price']} | ${item['date'].toString().split('.')[0]}'
              '\n${item['desc'] ?? ''}'
              '${item['receiptPath'] != null ? ' [Receipt Attached]' : ''}\n',
              style: pw.TextStyle(fontSize: 14),
            );
          }).toList(),
        ),
      ),
    );

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/grocery_list.pdf');
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ PDF exported to storage.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Tracker'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPDF,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _itemController,
              decoration: const InputDecoration(
                labelText: 'Enter item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter item price',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Enter description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(_selectedDateTime == null
                  ? 'Pick Date & Time'
                  : '${_selectedDateTime!.toLocal()}'.split('.')[0]),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: _uploadReceipt,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Receipt'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('No items yet.'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return ListTile(
                          title: Text('${item['name']} - \$${item['price']}'),
                          subtitle: Text(
                            '${item['date'].toString().split('.')[0]}\n'
                            '${item['desc'] ?? ''}' +
                            (item['receiptPath'] != null ? '\n📎 Receipt attached' : ''),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _removeItem(index),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
