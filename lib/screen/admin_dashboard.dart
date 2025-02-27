import 'package:catalog_app/others/alert_dialog.dart';
import 'package:catalog_app/screen/add_edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/database_helper.dart';
import 'login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  // Load products from the database
  void _loadProducts() async {
    final products = await DatabaseHelper.getProducts();
    setState(() {
      _products = products;
    });
  }

  // Delete a product
  void _deleteProduct(int id) async {
    await DatabaseHelper.deleteProduct(id);
    _loadProducts();
  }

  // Logout admin
  void _logout() async {
    showAlertDialog(
      title: "Logout",
      context: context,
      message: "Are you sure you want to logout?",
      onOkay: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();
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
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditProductScreen(),
                      ),
                    );
                    _loadProducts();
                  },
                  child: const Text("Add Product"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> item = _products[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  child: InkWell(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => AddEditProductScreen(
                                description: item["description"],
                                name: item["name"],
                                price: item["price"],
                                productId: item["id"],
                                stock: item["stock"],
                              ),
                        ),
                      );
                      _loadProducts();
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(_products[index]['name']),
                        subtitle: Text("₹${_products[index]['price']}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showAlertDialog(
                              title: "Save",
                              context: context,
                              message:
                                  "Are you sure you want to save the product?",
                              onOkay: () async {
                                _deleteProduct(_products[index]['id']);
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
