import 'dart:io';
import 'package:flutter/material.dart';
import '../models/grocery_item.dart';

class GroceryDetailScreen extends StatelessWidget {
  final GroceryItem item;

  const GroceryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Item Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🛒 ${item.name}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '💵 Price: \$${item.price}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '🕒 Added on: ${item.date.toString().split('.')[0]}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            if (item.desc != null && item.desc!.isNotEmpty)
              Text(
                '📝 Description:\n${item.desc!}',
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            if (item.receiptPath != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📷 Receipt:', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 10),
                  Image.file(File(item.receiptPath!), height: 200),
                ],
              )
            else
              const Text(
                '📎 No receipt uploaded.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
