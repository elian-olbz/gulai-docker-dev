To build gulai-web without using the image from dockerhub (dev mode)
.
├── docker-compose.yml
└── gulai-web
    ├── Dockerfile
    ├── README.md
    ├── django.log
    ├── entrypoint-dev.sh
    ├── gulai-django
    └── gulai-ws





docker-compose.yml:
"""
services:
  django:
    build: ./gulai-web
    container_name: django_dev
    working_dir: /app
    volumes:
      - ./gulai-web:/app  # mount Django code to docker container FS
    ports:
      - "8000:8000"             # Django dev server at http://localhost:8000
    environment:
      - DATABASE_URL=postgres://gulai_dev:password@db:5432/gulai_dev_db
      -  MEDIA_ROOT=gulai-django/
    depends_on:
      - db

  db:
    image: postgres:13
    container_name: postgres_dev
    restart: always
    environment:
      - POSTGRES_DB=gulai_dev_db
      - POSTGRES_USER=gulai_dev
      - POSTGRES_PASSWORD=password

    volumes:
      - pgdata_dev:/var/lib/postgresql/data

volumes:
  pgdata_dev:
""" 



Dockerfile

"""
FROM ubuntu:22.04

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget curl bzip2 ca-certificates git \
    netcat-openbsd \
&& rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh

# Add conda to PATH
ENV PATH="/opt/conda/bin:$PATH"


# Accept Anaconda TOS for pkgs/main and pkgs/r
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main && \
    conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda config --set channel_priority flexible

# Copy environment file
COPY gulai-django/environment.yml /tmp/environment.yml

# Create conda env
RUN conda env create -f /tmp/environment.yml

SHELL ["conda", "run", "-n", "gulai-django", "/bin/bash", "-c"]

# Copy rest of your code
WORKDIR /app
COPY . /app

# Entrypoint
ENTRYPOINT ["/app/entrypoint-dev.sh"]
"""






entrypoint-dev.sh (chmod +x)

"""
#!/bin/bash
set -e

export DJANGO_LOG_LEVEL=DEBUG
export DJANGO_SETTINGS_MODULE=gulai_project.settings.production

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
"""


first time run, seed data:
"""
sudo docker exec -it django_dev /opt/conda/envs/gulai-django/bin/python gulai-django/manage.py seed
"""
