# syntax=docker/dockerfile:experimental
# Dockerfile for drupal-static build

ARG REPOSITORY
ARG TAG
FROM ${REPOSITORY}/drupal:${TAG}

USER nginx

# Run composer install as application user:
# Normal startup (via /init) must also happen as root
USER root
COPY --chown=nginx:www-data codebase /var/www/drupal/
COPY --chown=0:0 rootfs /

RUN COMPOSER_MEMORY_LIMIT=-1 COMPOSER_DISCARD_CHANGES=true composer install --no-interaction --no-progress && \
    find /var/www/drupal/vendor \! -user nginx -exec chown -v nginx:www-data  {} \; && \
    chmod 0750 /var/www/drupal/fix_permissions.sh && \
    /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx  && \
    composer clearcache

