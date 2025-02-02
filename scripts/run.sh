#!/bin/sh

set -ue
set -x

basedir=$(cd $(dirname $0) && pwd)/..

# activate virtual environment
. $basedir/.venv/bin/activate

whoami

python manage.py wait_for_db
python manage.py collectstatic --noinput
python manage.py migrate

ls -la ${STATIC:-$basedir/static/}
ls -la ${MEDIA:-$basedir/media/}

export DEBUG=1

case "${APP_SERVER:-}" in
    gunicorn)
#            --bind=unix:${NGINX_TMPDIR:-$basedir/.devbox/virtenv/nginx/temp}/gunicorn.sock \
        gunicorn \
            --bind=:8000 \
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

