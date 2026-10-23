# OrderLokal

Phone ordering and delivery app for local shops. One Flutter app (Android first) on Firebase, with three roles: customer, owner, and delivery staff. Nothing in the code is tied to one shop: the owner enters the shop's name, area, and opening hours in the Shop tab, and the menu in the Menu tab.

Payments at launch: GCash by manual QR (customer enters the GCash reference number, owner confirms) and cash on delivery.

## Screens

| Menu | Cart | GCash payment | Order status |
| --- | --- | --- | --- |
| ![Menu](docs/screenshots/1-menu.png) | ![Cart](docs/screenshots/3-cart-top.png) | ![GCash](docs/screenshots/5-gcash.png) | ![Status](docs/screenshots/6-status.png) |

| Owner orders | Daily sales | Menu editor | Delivery staff |
| --- | --- | --- | --- |
| ![Orders](docs/screenshots/owner/1-owner-orders-new.png) | ![Sales](docs/screenshots/owner/4-owner-sales.png) | ![Menu editor](docs/screenshots/owner/5-owner-menu.png) | ![Delivery staff](docs/screenshots/owner/3-rider.png) |

The menu uses sample items and prices; the owner replaces them in the Menu tab. The web preview has no login: its first screen lets you try the app as a customer, the owner, or a delivery staff member, with everything kept in memory.

On a phone connected to Firebase, customers order without an account. The owner and delivery staff sign in from the menu's "Staff login". The first person to sign in there sets up the owner account, and the owner adds delivery staff logins in the Shop tab.

## Getting started

1. Install Flutter 3.47: https://docs.flutter.dev/get-started/install
2. `flutter pub get`, then `flutter test` and `flutter run`. Without Firebase settings the app runs as the offline preview.

## Connect Firebase

1. In the Firebase console, create a project and add an Android app with the package name `com.orderlokal.app`.
2. Turn on Authentication with the Anonymous and Email/Password sign-in methods.
3. Create a Firestore database, then paste `firestore.rules` into its Rules tab and publish.
4. Download `google-services.json` and copy its values into `lib/firebase_config.dart`. The file has the field names to look for.

## Release to Google Play

The release bundle is built on GitHub, so no Android tools are needed on your computer.

1. Run the **Make upload key** workflow once from the Actions tab. Download the `upload-key` file it makes, keep it somewhere safe, and add the four secrets listed in its `SECRETS.txt` under Settings > Secrets and variables > Actions. Then delete that workflow run.
2. Run the **Android release** workflow. When it finishes, download `app-release.aab` from the run's Artifacts.
3. In Play Console, create the app, open Testing > Internal testing, create a release, upload the `.aab`, and add testers by Gmail address. Testers open the link Play gives you to install the app.

Each run of the release workflow gets a new version code, so every bundle can be uploaded.
