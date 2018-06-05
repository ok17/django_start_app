#!/usr/bin/env bash

#git clone

PROJECT="init_project"

echo "Set your project name [default: init_project]:"
read input

if [ -n "$input" ]; then
    PROJECT=$input
fi

docker-sync start
docker-compose build app
docker-compose run --rm app pip install -r requirements.txt

# Change parameters as you like
docker-compose run --rm app django-admin.py startproject ${PROJECT} .

# Synchronize with the host side locally
docker-sync sync
cp ./.docker/template/local_settings.py ${PROJECT}/


cat <<EOF >> ${PROJECT}/__init__.py
import pymysql
pymysql.install_as_MySQLdb()
EOF

#macのsed(BSD sed)ではバックアップ拡張子が必須となるので''を指定している
sed -i '' "s/@PROJECT@/${PROJECT}/g" ${PROJECT}/local_settings.py
sed -i '' "s/@PROJECT@/${PROJECT}/g" docker-compose.yml

docker-compose run --rm app python manage.py makemigrations --settings=${PROJECT}.local_settings
docker-compose run --rm app python manage.py migrate --settings=${PROJECT}.local_settings
docker-compose run --rm app python manage.py createsuperuser --settings=${PROJECT}.local_settings

# git init
if [ -d ./.git ]; then
    rm -fr .git
fi

git init
cp .docker/.gitignore .

echo "finished!!"
echo "please start command [docker-compose up] "