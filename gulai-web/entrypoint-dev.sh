#!/bin/bash
set -e

export DJANGO_LOG_LEVEL=DEBUG
#export DJANGO_SETTINGS_MODULE=gulai_project.settings.production
export DJANGO_SETTINGS_MODULE=gulai_project.settings.development

source /opt/conda/etc/profile.d/conda.sh
conda activate gulai-django

# Wait for DB
echo "Waiting for database..."
until nc -z db 5432; do
  sleep 1
done

# Migrate every time
echo "Applying database migrations..."
python gulai-django/manage.py makemigrations --noinput
python gulai-django/manage.py migrate --noinput

# Collect static files
python gulai-django/manage.py collectstatic --noinput


echo "Starting server..."
exec python gulai-django/manage.py runserver 0.0.0.0:8000 --insecure

