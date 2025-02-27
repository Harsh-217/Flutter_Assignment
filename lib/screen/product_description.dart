import 'package:catalog_app/db/database_helper.dart';
import 'package:flutter/material.dart';

class ProductDescription extends StatefulWidget {
  final int productId;
  final String name;
  final double price;
  final int stock;
  final String description;

  const ProductDescription({
    super.key,
    required this.productId,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
  });

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Price: ₹${widget.price}",
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              "Stock: ${widget.stock > 0 ? widget.stock.toString() : "Out of Stock"}",
              style: TextStyle(
                fontSize: 18,
                color: widget.stock > 0 ? Colors.blue : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Description:",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(widget.description, style: const TextStyle(fontSize: 16)),
            const Spacer(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: ElevatedButton(
          onPressed: widget.stock > 0 ? () => _addToCart() : null,
          child: const Text("Add to Cart"),
        ),
      ),
    );
  }

  void _addToCart() async {
    Map<String, dynamic>? cartItem = await DatabaseHelper.getCartItemById(
      widget.productId,
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
              Text("How many ${widget.name} do you want to add?"),
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
                        opacity: tempQuantity.value < widget.stock ? 1 : 0.5,
                        child: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (tempQuantity.value == widget.stock) {
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
                  widget.productId,
                  widget.name,
                  widget.price,
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
}
