import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<MenuItem>? submenu;
  final List<String>? roles;

  const MenuItem({
    required this.label,
    required this.icon,
    this.route,
    this.submenu,
    this.roles,
  });
}

class NavigationConfig {
  static const List<MenuItem> items = [
    MenuItem(
      label: "Dashboard",
      icon: Icons.dashboard,
      route: "/dashboard",
      roles: ["admin", "manager", "accountant", "sales", "inventory"],
    ),
    MenuItem(
      label: "Masters",
      icon: Icons.content_cut, // Closest to Scissors
      roles: ["admin", "manager", "sales", "accountant", "inventory"],
      submenu: [
        MenuItem(
          label: "Add Materials",
          icon: Icons.add_circle_outline,
          route: "/masters/materials",
          roles: ["admin", "manager", "sales", "accountant", "inventory"],
        ),
        MenuItem(
          label: "Add Raw Materials",
          icon: Icons.raw_on,
          route: "/inventory/raw-materials",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Add Products",
          icon: Icons.add_box_outlined,
          route: "/masters/products",
          roles: ["admin", "manager", "sales", "inventory"],
        ),
      ],
    ),
    MenuItem(
      label: "Sales & Ops",
      icon: Icons.description, // Closest to FileText
      roles: ["admin", "manager", "sales", "accountant"],
      submenu: [
        MenuItem(
          label: "Add New Sale",
          icon: Icons.post_add,
          route: "/sales/add",
          roles: ["admin", "manager", "sales", "accountant"],
        ),
        MenuItem(
          label: "All Invoices List",
          icon: Icons.receipt_long,
          route: "/sales/invoices",
          roles: ["admin", "manager", "sales", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Inventory",
      icon: Icons.inventory_2, // Closest to PackageIcon
      roles: ["admin", "manager", "inventory", "accountant"],
      submenu: [
        MenuItem(
          label: "View Current Stock",
          icon: Icons.warehouse,
          route: "/inventory/stock",
          roles: ["admin", "manager", "inventory", "sales"],
        ),
        MenuItem(
          label: "Stock Production Entry",
          icon: Icons.precision_manufacturing,
          route: "/inventory/production",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Add/Remove Stock",
          icon: Icons.compare_arrows,
          route: "/inventory/adjust-stock",
          roles: ["admin", "manager", "inventory"],
        ),
      ],
    ),
    MenuItem(
      label: "Purchasing",
      icon: Icons.shopping_cart,
      roles: ["admin", "manager", "inventory", "accountant"],
      submenu: [
        MenuItem(
          label: "Purchases List",
          icon: Icons.list_alt,
          route: "/purchases",
          roles: ["admin", "manager", "inventory", "accountant"],
        ),
        MenuItem(
          label: "Add New Purchase",
          icon: Icons.add_shopping_cart,
          route: "/purchases/new",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Suppliers List",
          icon: Icons.people_alt_outlined,
          route: "/purchases/suppliers",
          roles: ["admin", "manager", "inventory", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Reports",
      icon: Icons.bar_chart,
      roles: ["admin", "manager", "accountant"],
      submenu: [
        MenuItem(
          label: "Sales Report",
          icon: Icons.analytics,
          route: "/reports/sales",
          roles: ["admin", "manager", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Customers",
      icon: Icons.people,
      route: "/customers",
      roles: ["admin", "manager", "sales", "accountant"],
    ),
    MenuItem(
      label: "Settings",
      icon: Icons.settings,
      roles: ["admin"],
      submenu: [
        MenuItem(
          label: "Users",
          icon: Icons.manage_accounts,
          route: "/users",
          roles: ["admin"],
        ),
      ],
    ),
  ];
}
