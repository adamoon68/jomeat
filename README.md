# JomEat

JomEat is a simple full-stack mobile app for student cafeteria food pre-orders. Students can view menu items from SQLite, place orders, edit pending order quantity and notes, cancel orders, and view order history. Admin users can add, update, and delete menu items.

## Features

- Student and admin registration/login
- Session saving with `shared_preferences`
- Food menu loaded from PHP API and SQLite
- Food detail page with quantity and notes
- Pre-order creation, order history, update, and cancellation
- Admin menu CRUD for food items
- JSON PHP API using PDO SQLite

## Tools Used

- Flutter
- PHP API
- SQLite database
- `http` package
- `shared_preferences` package

## Run The Backend

1. Copy the `backend_jomeat` folder into your PHP server folder:
   - XAMPP: `C:\xampp\htdocs\backend_jomeat`
   - Laragon: `C:\laragon\www\backend_jomeat`
2. Start Apache.
3. Run the setup page once:
   `http://localhost/backend_jomeat/database/setup_database.php`
4. Test menu API:
   `http://localhost/backend_jomeat/api/get_menu.php`

## Run The Flutter App

1. Install packages:
   `flutter pub get`
2. Check `lib/config.dart`.
   - Android emulator: `http://10.0.2.2/backend_jomeat/api`
   - Real phone: replace `10.0.2.2` with your computer IP address.
   - Hosted server: replace with your hosted domain URL.
3. Start an emulator or connect a phone.
4. Run:
   `flutter run`

## Sample Login Accounts

- Admin: `admin@jomeat.com` / `admin123`
- Student: `student@jomeat.com` / `student123`

## Test Food Pre-Order

1. Login as the sample student.
2. Tap a food item on the home menu.
3. Select quantity and enter notes such as `less spicy`.
4. Tap `Pre-order`.
5. Open order history from the receipt icon.
6. Edit quantity or cancel a pending order.

## Test Admin Menu CRUD

1. Login as the sample admin.
2. Tap `Admin Menu`.
3. Fill the form and tap `Add Food`.
4. Tap an existing menu item to load it into the form.
5. Edit details and tap `Update Food`.
6. Tap the delete icon to delete a food item. If it is already used in orders, the API marks it `Unavailable`.

## Common Errors And Fixes

- `Connection error`: confirm Apache is running and `baseUrl` in `lib/config.dart` matches your device.
- Android emulator cannot use `localhost`: use `10.0.2.2`.
- Real phone cannot use `10.0.2.2`: use your computer LAN IP, for example `http://192.168.1.10/backend_jomeat/api`.
- SQLite permission error: make sure the PHP server can write to `backend_jomeat/database`.
- Empty menu: run `setup_database.php` once and check that `backend_jomeat/database/jomeat.db` exists.

A new Flutter project.
