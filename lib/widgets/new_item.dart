import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_app/data/categories.dart';
import 'package:shopping_app/model/category.dart';
import 'package:shopping_app/model/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  String _enteredName = '';
  int _enteredQuanity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  bool _isSending = false;

  final _formKey = GlobalKey<FormState>();
  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'flutter-projects-3c113-default-rtdb.asia-southeast1.firebasedatabase.app',
          'shopping-list.json');
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
          {
            'name': _enteredName,
            'quantity': _enteredQuanity,
            'category': _selectedCategory.title,
          },
        ),
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      final Map<String, dynamic> reponseData = json.decode(response.body);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
            id: reponseData['name'],
            name: _enteredName,
            quantity: _enteredQuanity,
            category: _selectedCategory),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                    // under form widget
                    maxLength: 30,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text('Name'),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'must be between 1 and 50 characters.';
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _enteredName = newValue!;
                    }),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            label: Text('Quantity'),
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: _enteredQuanity.toString(),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                int.tryParse(value) == null ||
                                int.tryParse(value)! <= 0) {
                              return 'must be a valid, positive number.';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _enteredQuanity = int.parse(newValue!);
                          }),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final category in categories.entries)
                            DropdownMenuItem(
                                value: category.value,
                                child: Row(
                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: category.value.color),
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(category.value.title),
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formKey.currentState!.reset();
                            },
                      child: const Text('Reset'),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'),
                    ),
                  ],
                )
              ],
            )),
      ),
    );
  }
}
