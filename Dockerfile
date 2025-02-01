# Use UID of the logged in user
ARG UID

FROM python:3.9-alpine3.13

# re-import
ARG UID

ENV PYTHONUNBUFFERED 1

COPY ./requirements.txt /requirements.txt

RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-deps \
        build-base postgresql-dev musl-dev linux-headers && \
    /py/bin/pip install -r /requirements.txt && \
    apk del .tmp-deps

COPY ./scripts /scripts

RUN adduser -u ${UID} --disabled-password --no-create-home app && \
    mkdir -p /vol/web/static && \
    mkdir -p /vol/web/media && \
    chown -R ${UID} /vol && \
    chmod -R 755 /vol && \
    chmod -R +x /scripts

ENV PATH="/scripts:/py/bin:$PATH"

WORKDIR /app
EXPOSE 8000

USER app

COPY ./app /app

CMD ["/scripts/run.sh"]
