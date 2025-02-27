import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const String _databaseName = "user_database.db";
  static const String _userTable = "users";
  static const String _productTable = "products";
  static const String _cartTable = "cart";

  static Future<Database> get database async {
  return openDatabase(
    join(await getDatabasesPath(), _databaseName),
    onCreate: (db, version) async {
      // Create user table
      await db.execute(
        "CREATE TABLE $_userTable(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT UNIQUE, password TEXT)",
      );

      // Insert Admin User
      await db.execute(
        "INSERT INTO $_userTable (email, password) VALUES ('admin.example@gmail.com', 'admin1234')"
      );

      // Create product table
      await db.execute(
        "CREATE TABLE $_productTable(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, price REAL, stock INTEGER, description TEXT)"
      );

      // Create cart table
      await db.execute(
        "CREATE TABLE $_cartTable(id INTEGER PRIMARY KEY AUTOINCREMENT, productId INTEGER, name TEXT, price REAL, quantity INTEGER)",
      );
    },
    version: 1,
  );
}


  static Future<Map<String, dynamic>?> getProductById(int id) async {
  final db = await database;

  List<Map<String, dynamic>> productMaps = await db.query(
    _productTable,
    where: "id = ?",
    whereArgs: [id],
  );

  if (productMaps.isNotEmpty) {
    return productMaps.first; // Convert the first result to Product object
  } else {
    return null; // Return null if no product found
  }
}


  // User Functions
  static Future<bool> checkEmailExists(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      _userTable,
      where: "email = ?",
      whereArgs: [email],
    );
    return users.isNotEmpty;
  }

  static Future<void> insertUser(String email, String password) async {
    final db = await database;
    await db.insert(_userTable, {
      'email': email,
      'password': password,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<bool> checkUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> users = await db.query(
      _userTable,
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
    );
    return users.isNotEmpty;
  }

  // Product Functions
  static Future<void> addProduct(String name, double price, int stock, String description) async {
  final db = await database;
  await db.insert(_productTable, {
    'name': name,
    'price': price,
    'stock': stock,
    'description': description,
  });
}


  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return await db.query(_productTable);
  }

  static Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(_productTable, where: "id = ?", whereArgs: [id]);
  }

  // Cart Functions
  static Future<void> addToCart(
    int productId,
    String name,
    double price,
    int quantity,
  ) async {
    final db = await database;

    // Check if item already exists
    List<Map<String, dynamic>> existingItems = await db.query(
      _cartTable,
      where: "productId = ?",
      whereArgs: [productId],
    );

    if (existingItems.isNotEmpty) {

      if (quantity <= 0) {
        // If quantity becomes zero or negative, remove from cart
        await db.delete(
          _cartTable,
          where: "productId = ?",
          whereArgs: [productId],
        );
      } else {
        // Otherwise, update the quantity
        await db.update(
          _cartTable,
          {'quantity': quantity},
          where: "productId = ?",
          whereArgs: [productId],
        );
      }
    } else if (quantity > 0) {
      // Insert new product only if quantity is greater than zero
      await db.insert(_cartTable, {
        'productId': productId,
        'name': name,
        'price': price,
        'quantity': quantity,
      });
    }
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await database;
    return await db.query(_cartTable);
  }

  static Future<void> removeFromCart(int id) async {
    final db = await database;

    List<Map<String, dynamic>> items = await db.query(
      _cartTable,
      where: "id = ?",
      whereArgs: [id],
    );

    if (items.isNotEmpty) {
      int newQuantity = items.first['quantity'] - 1;
      if (newQuantity > 0) {
        await db.update(
          _cartTable,
          {'quantity': newQuantity},
          where: "id = ?",
          whereArgs: [id],
        );
      } else {
        await db.delete(_cartTable, where: "id = ?", whereArgs: [id]);
      }
    }
  }

  static Future<void> updateCartQuantity(int id, int quantity) async {
    final db = await database;
    await db.update(
      _cartTable,
      {'quantity': quantity},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  static Future<Map<String, dynamic>?> getCartItemById(int id) async {
  final db = await database;
  
  List<Map<String, dynamic>> cartItems = await db.query(
    _cartTable,
    where: "productId = ?",
    whereArgs: [id],
  );

  if (cartItems.isNotEmpty) {
    return cartItems.first; // Return the first matching cart item
  } else {
    return null; // Return null if no item found
  }
}

  static Future<void> clearCart() async {
    final db = await database;
    await db.delete(_cartTable);
  }

  static Future<void> updateProduct(int id, String name, double price, int stock, String description) async {
  final db = await database;
  await db.update(
    _productTable,
    {'name': name, 'price': price, 'stock': stock, 'description': description},
    where: "id = ?",
    whereArgs: [id],
  );
}

}

