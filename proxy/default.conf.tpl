upstream app_server {
    server ${APP_HOST}:${APP_PORT};
}

server {
    listen ${LISTEN_PORT};

    location /static {
        alias /vol/static;
    }

    location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        if (!-f $request_filename) {
            proxy_pass http://app_server;
            break;
        }
        client_max_body_size    10M;
    }
}
