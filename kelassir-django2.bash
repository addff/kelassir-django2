#!/bin/bash
# Semak keperluan asas
command -v docker >/dev/null || { echo "Docker tidak dijumpai."; exit 1; }
command -v docker-compose >/dev/null || { echo "Docker Compose tidak dijumpai."; exit 1; }

# Masuk ke direktori kelassir
cd kelassir

# Semak jika Django sudah wujud
if [ -d "django2/django2" ]; then
  echo "Django sudah wujud. Langkau create-project."
else
  echo "Menjana projek Django..."
  sudo docker run --rm -v "$PWD":/app -w /app python:3.11-slim \
    sh -c "pip install Django && django-admin startproject django2"
fi

sudo docker-compose up -d

# Tunggu Django container siap
echo "Menunggu Django container untuk sedia..."
while ! sudo docker exec kelassir_django2_web bash -c "echo 'ready';" 2>/dev/null; do
  sleep 1
done
echo " ..... finished."

# Set full permission temporary
sudo chmod 777 django2/django2/settings.py
echo "ALLOWED_HOSTS = ['*']" >> django2/django2/settings.py

echo "Finale..."
sudo docker exec kelassir_django2_web bash -c "cd django2; python manage.py migrate"
sudo docker-compose logs -f
