# syntax=docker/dockerfile:experimental
ARG REPOSITORY
ARG TAG
FROM ${REPOSITORY}/drupal:${TAG}

COPY --chown=0:0 rootfs /
COPY --chown=nginx:www-data codebase /var/www/drupal/

USER nginx
RUN echo "Creating tmp directory " && \
    mkdir -m 0775 -p /var/www/drupal/web/sites/default/files/tmp && \
    mkdir -m 0755 -p /tmp/private && \
    echo "Copy Generic File" && \
    if [ ! -f web/sites/default/files/generic.png ] ; then \
      cp "web/core/modules/media/images/icons/generic.png" "web/sites/default/files/generic.png" ; \
    fi

USER root
# Final permissions sets:
RUN bash /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx

# Run composer install as application user:
USER nginx
RUN COMPOSER_MEMORY_LIMIT=-1 COMPOSER_DISCARD_CHANGES=true composer install --no-interaction --no-progress

# Normal startup (via /init) must happen as root:
USER root

