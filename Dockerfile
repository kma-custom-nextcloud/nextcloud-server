FROM nextcloud:22

COPY  /apps /usr/src/nextcloud/apps
COPY  /core /usr/src/nextcloud/core
COPY  /lib /usr/src/nextcloud/lib
COPY  /resources /usr/src/nextcloud/resources

COPY sync /usr/bin/sync-nc-core
RUN chmod +x /usr/bin/sync-nc-core
