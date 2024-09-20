import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:shopping_list_app/models/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => NewItemState();
}

class NewItemState extends State<NewItem> {
  final _formkey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;
  var _isSending = false;

  void _saveItem() async {
    final url = Uri.https(
        'shopping-list-app-5947d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list-app.json');
    try {
      if (_formkey.currentState!.validate()) {
        _formkey.currentState!.save();
        setState(() {
          _isSending = true;
        });

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(
            {
              'name': _enteredName,
              'quantity': _enteredQuantity,
              'category': _selectedCategory.title,
            },
          ),
        );
        final Map<String, dynamic> resData = json.decode(response.body);
        
        if (!context.mounted) {
          return;
        }
        Navigator.of(context).pop(GroceryItem(
            id: resData['name'],
            name: _enteredName,
            quantity: _enteredQuantity,
            category: _selectedCategory));
        // Navigator.of(context).pop(GroceryItem(
        //     id: DateTime.now().toString(),
        //     name: _enteredName,
        //     quantity: _enteredQuantity,
        //     category: _selectedCategory));
      }
    } catch (error) {
      _showDialog();
    }
  }

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Unexpected Error Occured'),
          content: const Text('Please try again later.'),
          actions: [
            TextButton(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OKAY',
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Unexpected Error Occured'),
          content: const Text('Please try again later.'),
          actions: [
            TextButton(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OKAY',
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formkey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (newValue) {
                  _enteredName = newValue!;
                },
                maxLength: 50,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      onSaved: (newValue) {
                        _enteredQuantity = int.parse(newValue!);
                      },
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.title),
                              ],
                            ),
                          )
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: _isSending
                          ? null
                          : () {
                              _formkey.currentState!.reset();
                            },
                      child: const Text('Reset')),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : const Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
