##To build gulai-web without using the image from dockerhub (dev mode)
```
.
├── docker-compose.yml
└── gulai-web
    ├── Dockerfile
    ├── README.md
    ├── django.log
    ├── entrypoint-dev.sh
    ├── gulai-django
    └── gulai-ws
```


##entrypoint-dev.sh (chmod +x)

first time run, seed data:
```
sudo docker exec -it django_dev /opt/conda/envs/gulai-django/bin/python gulai-django/manage.py seed
```
