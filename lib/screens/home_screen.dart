import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grocery_tracker/screens/grocery_detail_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/grocery_item.dart';
import '../services/grocery_service.dart';
import '../widgets/custom_input_field.dart'; // Importing the custom widget

class GroceryHomeScreen extends StatefulWidget {
  const GroceryHomeScreen({super.key});

  @override
  State<GroceryHomeScreen> createState() => _GroceryHomeScreenState();
}

class _GroceryHomeScreenState extends State<GroceryHomeScreen> {
  final List<GroceryItem> _items = [];
  final _service = GroceryService();
  final _itemController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;
  File? _receipt;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final loaded = await _service.loadItems();
    setState(() => _items.addAll(loaded));
  }

  Future<void> _saveItems() async => await _service.saveItems(_items);

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return; // ✅ Add this line

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _selectedDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _addItem() {
    if (_itemController.text.trim().isEmpty ||
        _priceController.text.trim().isEmpty) {
      return;
    }

    final item = GroceryItem(
      name: _itemController.text.trim(),
      price: _priceController.text.trim(),
      desc: _descController.text.trim(),
      date: _selectedDate ?? DateTime.now(),
      receiptPath: _receipt?.path,
    );

    setState(() {
      _items.add(item);
      _itemController.clear();
      _priceController.clear();
      _descController.clear();
      _receipt = null;
      _selectedDate = null;
    });

    _saveItems();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
    _saveItems();
  }

  Future<void> _uploadReceipt() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _receipt = File(picked.path);
      });
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build:
            (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children:
                  _items.map((item) {
                    return pw.Text(
                      '${item.name} - \$${item.price} | ${item.date.toString().split('.')[0]}\n'
                      '${item.desc ?? ''}'
                      '${item.receiptPath != null ? ' [📎 Receipt Attached]' : ''}\n',
                    );
                  }).toList(),
            ),
      ),
    );

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/grocery_list.pdf');
    await file.writeAsBytes(await pdf.save());

    if (!mounted) return; // ✅ Important check before using context

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ PDF exported successfully")),
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInputField(label: 'Item Name', controller: _itemController),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _priceController,
              label: 'Item Price',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            CustomInputField(
              controller: _descController,
              label: 'Description',
              maxLines: 2,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickDateTime,
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _selectedDate == null
                    ? 'Pick Date & Time'
                    : '${_selectedDate!.toLocal()}'.split('.')[0],
              ),
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
              child:
                  _items.isEmpty
                      ? const Center(child: Text('No items yet.'))
                      : ListView.builder(
                        itemCount: _items.length,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => GroceryDetailScreen(item: item),
                                ),
                              );
                            },
                            title: Text('${item.name} - \$${item.price}'),
                            subtitle: Text(
                              '${item.date.toString().split('.')[0]}\n${item.desc ?? ''}${item.receiptPath != null ? '\n📎 Receipt attached' : ''}',
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
