#!/bin/sh

set -ue
set -x

basedir=$(cd $(dirname $0) && pwd)/..
ls -la ${STATIC:-$basedir/data/web/static}
ls -la ${MEDIA:-$basedir/data/web/media}

whoami

python manage.py wait_for_db
python manage.py collectstatic --noinput
python manage.py migrate

case "${DEBUG:-0}" in
    0)
        uwsgi --http 9000 --workers 4 --master --enable-threads --module app.wsgi
        ;;
    *)
        python manage.py runserver 8000
        ;;
esac

