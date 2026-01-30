import 'package:flutter/cupertino.dart';
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
      icon: CupertinoIcons.home,
      route: "/dashboard",
      roles: ["admin", "manager", "accountant", "sales", "inventory"],
    ),
    MenuItem(
      label: "Masters",
      icon: CupertinoIcons.layers,
      roles: ["admin", "manager", "sales", "accountant", "inventory"],
      submenu: [
        MenuItem(
          label: "Add Materials",
          icon: CupertinoIcons.add_circled,
          route: "/masters/materials",
          roles: ["admin", "manager", "sales", "accountant", "inventory"],
        ),
        MenuItem(
          label: "Add Raw Materials",
          icon: CupertinoIcons.cube_box,
          route: "/inventory/raw-materials",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Add Products",
          icon: CupertinoIcons.cube_box_fill,
          route: "/masters/products",
          roles: ["admin", "manager", "sales", "inventory"],
        ),
      ],
    ),
    MenuItem(
      label: "Sales & Ops",
      icon: CupertinoIcons.doc_text,
      roles: ["admin", "manager", "sales", "accountant"],
      submenu: [
        MenuItem(
          label: "Add New Sale",
          icon: CupertinoIcons.plus_rectangle,
          route: "/sales/add",
          roles: ["admin", "manager", "sales", "accountant"],
        ),
        MenuItem(
          label: "All Invoices List",
          icon: CupertinoIcons.doc_text_search,
          route: "/sales/invoices",
          roles: ["admin", "manager", "sales", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Inventory",
      icon: CupertinoIcons.archivebox,
      roles: ["admin", "manager", "inventory", "accountant"],
      submenu: [
        MenuItem(
          label: "View Current Stock",
          icon: CupertinoIcons.building_2_fill,
          route: "/inventory/stock",
          roles: ["admin", "manager", "inventory", "sales"],
        ),
        MenuItem(
          label: "Stock Production Entry",
          icon: CupertinoIcons.arrow_2_circlepath_circle,
          route: "/inventory/production",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Add/Remove Stock",
          icon: CupertinoIcons.arrow_right_arrow_left,
          route: "/inventory/adjust-stock",
          roles: ["admin", "manager", "inventory"],
        ),
      ],
    ),
    MenuItem(
      label: "Purchasing",
      icon: CupertinoIcons.shopping_cart,
      roles: ["admin", "manager", "inventory", "accountant"],
      submenu: [
        MenuItem(
          label: "Purchases List",
          icon: CupertinoIcons.list_bullet,
          route: "/purchases",
          roles: ["admin", "manager", "inventory", "accountant"],
        ),
        MenuItem(
          label: "Add New Purchase",
          icon: CupertinoIcons.cart_badge_plus,
          route: "/purchases/new",
          roles: ["admin", "manager", "inventory"],
        ),
        MenuItem(
          label: "Suppliers List",
          icon: CupertinoIcons.person_2,
          route: "/purchases/suppliers",
          roles: ["admin", "manager", "inventory", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Reports",
      icon: CupertinoIcons.chart_bar,
      roles: ["admin", "manager", "accountant"],
      submenu: [
        MenuItem(
          label: "Sales Report",
          icon: CupertinoIcons.graph_square,
          route: "/reports/sales",
          roles: ["admin", "manager", "accountant"],
        ),
      ],
    ),
    MenuItem(
      label: "Customers",
      icon: CupertinoIcons.person_3,
      route: "/customers",
      roles: ["admin", "manager", "sales", "accountant"],
    ),
    MenuItem(
      label: "Settings",
      icon: CupertinoIcons.settings,
      roles: ["admin"],
      submenu: [
        MenuItem(
          label: "Users",
          icon: CupertinoIcons.person_crop_circle_badge_checkmark,
          route: "/users",
          roles: ["admin"],
        ),
      ],
    ),
  ];
}
