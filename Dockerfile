# syntax=docker/dockerfile:experimental
ARG REPOSITORY
ARG TAG
FROM ${REPOSITORY}/drupal:${TAG}

COPY --chown=0:0 rootfs /
COPY --chown=nginx:www-data codebase /var/www/drupal/

RUN bash /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx

# Run composer install as application user:
USER nginx
RUN COMPOSER_MEMORY_LIMIT=-1 COMPOSER_DISCARD_CHANGES=true composer install --no-interaction --no-progress

# Normal startup (via /init) must happen as root:
USER root

