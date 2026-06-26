#!/bin/sh
set -e

# Install ulang dependency kalau vendor hilang (ketimpa bind mount volume)
if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
  echo ">> vendor/ tidak ditemukan, jalanin composer install..."
  composer install --optimize-autoloader --no-interaction
fi

# Generate APP_KEY kalau kosong
if ! grep -q "^APP_KEY=base64" .env 2>/dev/null; then
  echo ">> generate APP_KEY..."
  php artisan key:generate --force
fi

# Siapkan database sqlite
mkdir -p database
touch database/database.sqlite

echo ">> migrate database..."
php artisan migrate --force

echo ">> cek apakah perlu seed data contoh..."
ROW_COUNT=$(php artisan tinker --execute="echo \DB::table('transactions')->count();" 2>/dev/null | tail -1)
if [ "$ROW_COUNT" = "0" ]; then
  echo ">> tabel transactions kosong, jalankan seeder..."
  php artisan db:seed --force --class=TransactionSeeder
else
  echo ">> tabel transactions sudah ada data ($ROW_COUNT baris), skip seeding."
fi

php artisan config:clear
php artisan route:clear

echo ">> siap, jalankan server..."
exec php artisan serve --host=0.0.0.0 --port=8000