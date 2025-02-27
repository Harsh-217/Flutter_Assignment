import 'package:catalog_app/others/alert_dialog.dart';
import 'package:catalog_app/screen/product_description.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import 'cart_screen.dart';
import 'login_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  ProductListScreenState createState() => ProductListScreenState();
}

class ProductListScreenState extends State<ProductListScreen> {
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    final productMaps = await DatabaseHelper.getProducts();

    setState(() {
      _products = productMaps;
    });
  }

  void _addToCart(Map<String, dynamic> currentProduct) async {
    Map<String, dynamic>? cartItem = await DatabaseHelper.getCartItemById(
      currentProduct["id"],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        ValueNotifier<int> tempQuantity = ValueNotifier(
          cartItem?["quantity"] ?? 0,
        );
        return AlertDialog(
          title: const Text("Select Quantity"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("How many ${currentProduct["name"]} do you want to add?"),
              const SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: tempQuantity,
                builder: (context, value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (tempQuantity.value > 1) {
                            tempQuantity.value--;
                          }
                        },
                      ),
                      Text(
                        tempQuantity.value.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      Opacity(
                        opacity:
                            tempQuantity.value < currentProduct["stock"]
                                ? 1
                                : 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (tempQuantity.value == currentProduct["stock"]) {
                              return;
                            }
                            tempQuantity.value++;
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Add to Cart"),
              onPressed: () {
                DatabaseHelper.addToCart(
                  currentProduct["id"],
                  currentProduct["name"],
                  currentProduct["price"],
                  tempQuantity.value,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Added to Cart!")));
              },
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    showAlertDialog(
      title: "Logout",
      context: context,
      message: "Are you sure you want to logout?",
      onOkay: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await DatabaseHelper.clearCart();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _products.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = _products[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProductDescription(
                          description: item["description"],
                          name: item["name"],
                          price: item["price"],
                          productId: item["id"],
                          stock: item["stock"],
                        ),
                  ),
                );
              },
              child: Card(
                child: ListTile(
                  title: Text(item["name"]),
                  subtitle: Text("₹${item["price"]}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.green,
                        ),
                        onPressed: () => _addToCart(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
