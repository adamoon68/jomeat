JomEat Backend Setup

1. Copy the backend_jomeat folder into XAMPP htdocs or a PHP server folder.

Examples:
- XAMPP: C:\xampp\htdocs\backend_jomeat
- Laragon: C:\laragon\www\backend_jomeat

2. Start Apache.

3. Run setup_database.php once in browser:
http://localhost/backend_jomeat/database/setup_database.php

4. Test API:
http://localhost/backend_jomeat/api/get_menu.php

5. SQLite database location:
backend_jomeat/database/jomeat.db

6. Uploaded food image location:
assets/images

Make sure PHP/Apache can write to:
- backend_jomeat/database
- assets/images

Sample accounts:
- Admin: admin@jomeat.com / admin123
- Student: student@jomeat.com / student123

If you get a SQLite permission error, allow write permission for the backend_jomeat/database folder.
If image upload fails, allow write permission for the assets/images folder.
