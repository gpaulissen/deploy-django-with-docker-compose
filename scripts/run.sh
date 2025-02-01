#!/bin/sh

set -e

ls -la /vol/
ls -la /vol/web

whoami

python manage.py wait_for_db
python manage.py collectstatic --noinput
python manage.py migrate

case "${DEBUG:-0}" in
    0)
        uwsgi --socket :9000 --workers 4 --master --enable-threads --module app.wsgi
        ;;
    *)
        python manage.py runserver 0.0.0.0:8000
        ;;
esac

