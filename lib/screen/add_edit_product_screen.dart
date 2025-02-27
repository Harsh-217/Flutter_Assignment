import 'package:catalog_app/screen/admin_dashboard.dart';
import 'package:catalog_app/others/alert_dialog.dart';
import 'package:catalog_app/db/database_helper.dart';
import 'package:flutter/material.dart';

class AddEditProductScreen extends StatefulWidget {
  final int? productId; // If null, it's an add operation
  final String? name;
  final double? price;
  final int? stock;
  final String? description;

  const AddEditProductScreen({
    super.key,
    this.productId,
    this.name,
    this.price,
    this.stock,
    this.description,
  });

  @override
  AddEditProductScreenState createState() => AddEditProductScreenState();
}

class AddEditProductScreenState extends State<AddEditProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      _nameController.text = widget.name ?? "";
      _priceController.text = widget.price?.toString() ?? "";
      _stockController.text = widget.stock?.toString() ?? "";
      _descriptionController.text = widget.description ?? "";
    }
  }

  void _saveProduct() async {
    String name = _nameController.text.trim();
    double? price = double.tryParse(_priceController.text.trim());
    int? stock = int.tryParse(_stockController.text.trim());
    String description = _descriptionController.text.trim();

    if (name.isEmpty ||
        price == null ||
        price <= 0 ||
        stock == null ||
        stock < 0 ||
        description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid product details!")),
      );
      return;
    }

    if (widget.productId == null) {
      // Add new product
      await DatabaseHelper.addProduct(name, price, stock, description);
    } else {
      // Edit existing product
      await DatabaseHelper.updateProduct(
        widget.productId!,
        name,
        price,
        stock,
        description,
      );
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => AdminDashboard()),
      (Route<dynamic> route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? "Add Product" : "Edit Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _stockController,
              decoration: const InputDecoration(labelText: "Stock"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Description (Max 100 chars)",
              ),
              maxLength: 100, // Limit to 100 characters
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: () {
            showAlertDialog(
              title: "Save",
              context: context,
              message: "Are you sure you want to save the product?",
              onOkay: () async {
                _saveProduct();
              },
            );
          },
          child: Text(
            widget.productId == null ? "Add Product" : "Update Product",
          ),
        ),
      ),
    );
  }
}
