# 🛒 Shopee - Flutter E-commerce Application

## 📌 Overview

Shopee is a **Flutter-based e-commerce application** supporting both **Admin and Customer** roles. It offers **authentication, product management, cart functionality, and a checkout process**.

---

## 🔑 Features

### **1️⃣ Authentication**

- **Admin Login:** Access with specific credentials.

    Email - "<admin.example@gmail.com>", Password - "admin1234".
- **Customer Login:** Access with general user credentials.

### **2️⃣ Admin Capabilities**

- Add, edit, view, and delete products.

### **3️⃣ Customer Capabilities**

- Browse product listings and view detailed information.
- Add products to a cart with specified quantities.
- Review cart contents and proceed to checkout.

### **4️⃣ Additional Features**

- **SQLite Database** for storing products and user sessions.
- **User Dialogs** for logout confirmation.

---

## 📂 Project Structure

/shopee_app  
│── /lib  
│   │── /db  
│   │   ├── database_helper.dart  # Handles SQLite operations  
│   │── /others  
│   │   ├── alert_dialog.dart          # Open a common Dialog

│   │── /screens  
│   │   ├── login_screen.dart      # User authentication interface  
│   │   ├── admin_dashboard.dart   # Admin functionalities  
│   │   ├── product_list_screen.dart # Product listing for customers  
│   │   ├── product_description.dart # Detailed product view  
│   │   ├── cart_screen.dart       # Shopping cart interface  
│   │   ├── checkout_screen.dart   # Checkout process  
│   │── main.dart                  # Application entry point  
│── pubspec.yaml                    # Dependencies  
│── README.md                        # Documentation  
