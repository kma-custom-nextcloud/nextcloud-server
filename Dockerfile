FROM nextcloud:22

COPY . /usr/src/nextcloud

COPY sync /usr/bin/sync-nc-core
RUN chmod +x /usr/bin/sync-nc-core
