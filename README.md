# Dolebee ordering app

Phone ordering and delivery app for Dolebee fried chicken in Poblacion, Hinunangan, Southern Leyte. One Flutter app (Android first) on Firebase, with three roles: customer, owner, and delivery staff.

## What is here

- `lib/models/` holds menu items, orders, and delivery zones (PHP 20 up to 2 km, PHP 40 up to 5 km, PHP 60 up to 8 km).
- `lib/services/daily_sales.dart` computes the owner's daily sales and the monthly app fee.
- `firestore.rules` restricts who can read and change orders and menu items.
- `lib/screens/` has the customer screens, the owner screens (`owner/`: orders, daily sales, menu editor), and the delivery staff screen (`rider/`).
- `test/` covers zone fees, daily sales, the app fee, and the customer, owner, and delivery staff flows.

Payments at launch: GCash by manual QR (customer enters the GCash reference number, owner confirms) and cash on delivery.

## Screens

| Menu | Cart | GCash payment | Order status |
| --- | --- | --- | --- |
| ![Menu](docs/screenshots/1-menu.png) | ![Cart](docs/screenshots/3-cart-top.png) | ![GCash](docs/screenshots/5-gcash.png) | ![Status](docs/screenshots/6-status.png) |

| Owner orders | Daily sales | Menu editor | Delivery staff |
| --- | --- | --- | --- |
| ![Orders](docs/screenshots/owner/1-owner-orders-new.png) | ![Sales](docs/screenshots/owner/4-owner-sales.png) | ![Menu editor](docs/screenshots/owner/5-owner-menu.png) | ![Delivery staff](docs/screenshots/owner/3-rider.png) |

The menu uses sample items and prices; the owner replaces them in the Menu tab. Until login is added, the first screen lets you preview the app as a customer, the owner, or a delivery staff member.

## Getting started

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Create a Firebase project, then run `dart pub global activate flutterfire_cli` and `flutterfire configure`.
3. `flutter pub get`, then `flutter test` and `flutter run`.
