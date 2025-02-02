#!/bin/sh

set -ue
set -x

basedir=$(cd $(dirname $0) && pwd)/..
ls -la ${STATIC:-$basedir/data/web/static/}
ls -la ${MEDIA:-$basedir/data/web/media/}

whoami

python manage.py wait_for_db
python manage.py collectstatic --noinput
python manage.py migrate

export DEBUG=1

case "${APP_SERVER:-}" in
    gunicorn)
        gunicorn \
            --bind=unix:$NGINX_TMPDIR/gunicorn.sock \
            --workers=${WORKERS:-4} \
            --threads=${THREADS:-2} \
            app.wsgi
        ;;
    uwsgi)
        uwsgi --socket :8000 --workers 4 --master --enable-threads --module app.wsgi
        ;;
    *)
        DEBUG=0
        python manage.py runserver 8000
        ;;
esac

