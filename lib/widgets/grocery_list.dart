import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'shopping-list-app-5947d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list-app.json');

    final response = await http.get(url);

    if (response.body == 'null') {
      return [];
    } else if (response.statusCode >= 400) {
      // setState(() {
      //   _error = 'Failed to load data. Please try again later';
      // });
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category),
      );
    }
    return loadedItems;
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
      _loadedItems = _loadItems();
    });
  }

  void _removeGroceryItem(GroceryItem item) async {
    final groceryIndex = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
        'shopping-list-app-5947d-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list-app/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(groceryIndex, item);
      });
    }
    // ScaffoldMessenger.of(context).clearSnackBars();
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //   content: const Text('Grocery Item Deleted'),
    //   action: SnackBarAction(
    //     label: 'Undo',
    //     onPressed: () {
    //       setState(() {
    //         _groceryItems.insert(groceryIndex, item);
    //       });
    //     },
    //   ),
    //   duration: const Duration(seconds: 3),
    // ));
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.data!.isNotEmpty) {
            return Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 55,
                    ),
                    Expanded(
                        flex: 3,
                        child: Text(
                          'Name',
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                    Expanded(
                        child: Text(
                      'Quantity',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ))
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => Dismissible(
                      background: Container(
                        color: Theme.of(context)
                            .colorScheme
                            .error
                            .withOpacity(0.8),
                      ),
                      onDismissed: (direction) {
                        _removeGroceryItem(snapshot.data![index]);
                      },
                      key: UniqueKey(),
                      child: ListTile(
                        title: Text(snapshot.data![index].name),
                        leading: Container(
                          width: 24,
                          height: 24,
                          color: snapshot.data![index].category.color,
                        ),
                        trailing: Text(
                          snapshot.data![index].quantity.toString(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    // itemBuilder: (context, index) => ListTile(
                    //   title: Text(_groceryItems[index].name),
                    //   leading: Container(
                    //     width: 24,
                    //     height: 24,
                    //     color: _groceryItems[index].category.color,
                    //   ),
                    //   trailing: Text(
                    //     _groceryItems[index].quantity.toString(),
                    //     style: Theme.of(context).textTheme.bodySmall,
                    //   ),
                    // ),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Text(
                'You have no items yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
        },
      ),
    );
  }
}
