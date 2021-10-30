FROM nextcloud:22

COPY ./core /usr/src/nextcloud/core

COPY sync /usr/bin/sync-nc-core
RUN chmod +x /usr/bin/sync-nc-core
