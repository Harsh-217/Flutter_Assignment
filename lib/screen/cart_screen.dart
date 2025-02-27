import 'package:catalog_app/screen/product_list_screen.dart';
import 'package:flutter/material.dart';
import '../db/database_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _loadCart() async {
    final cartItems = await DatabaseHelper.getCartItems();
    setState(() {
      _cartItems = cartItems;
    });
  }

  void _removeFromCart(int id) async {
    await DatabaseHelper.removeFromCart(id);
    _loadCart();
  }

  void _checkout() async {
    for (Map<String, dynamic> cartItem in _cartItems) {
      Map<String, dynamic>? product = await DatabaseHelper.getProductById(
        cartItem["productId"],
      );

      if (product != null) {
        await DatabaseHelper.updateProduct(
          product["id"],
          product["name"],
          product["price"],
          product["stock"] - cartItem["quantity"],
          product["description"],
        );
      }
    }
    await DatabaseHelper.clearCart();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order Placed Successfully!")));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ProductListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body:
          _cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty!"))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_cartItems[index]['name']),
                          subtitle: Text(
                            "₹${_cartItems[index]['price']} x ${_cartItems[index]['quantity']}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  if (_cartItems[index]['quantity'] > 1) {
                                    DatabaseHelper.updateCartQuantity(
                                      _cartItems[index]['id'],
                                      _cartItems[index]['quantity'] - 1,
                                    );
                                    _loadCart();
                                  } else {
                                    _removeFromCart(_cartItems[index]['id']);
                                  }
                                },
                              ),
                              Text(
                                _cartItems[index]['quantity'].toString(),
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.add_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  DatabaseHelper.updateCartQuantity(
                                    _cartItems[index]['id'],
                                    _cartItems[index]['quantity'] + 1,
                                  );
                                  _loadCart();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      bottomNavigationBar:
          _cartItems.isEmpty
              ? null
              : BottomAppBar(
                child: ElevatedButton(
                  onPressed: _checkout,
                  child: const Text("Checkout"),
                ),
              ),
    );
  }
}
