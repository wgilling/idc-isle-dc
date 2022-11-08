#!/usr/bin/with-contenv bash

set -e
echo ""
echo ""
echo " -------------------------------------------------------------------------- "
echo " -              Running a Start up script                                 - "
echo " -------------------------------------------------------------------------- "
echo ""

COMPOSER_MEMORY_LIMIT=-1 COMPOSER_DISCARD_CHANGES=true composer install --no-interaction --no-progress

bash /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx

# This is a workaround for a bug.
drush cdel core.extension module.search_api_solr_defaults || true
drush sql-query "DELETE FROM key_value WHERE collection='system.schema' AND name='search_api_solr_defaults';" || true
drush php-eval "\Drupal::keyValue('system.schema')->delete('remote_stream_wrapper')" || true
drush php-eval "\Drupal::keyValue('system.schema')->delete('matomo')" || true

drush config:import -y

# Fix for Github runner "the input device is not a TTY" error
bash /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx
drush search-api-solr:install-missing-fieldtypes || true
drush search-api:rebuild-tracker || true
drush search-api-solr:finalize-index || true
drush search-api:index || true

# Cleanup
drush updatedb -y
drush cc theme-registry
drush -d status

echo ""
echo ""
echo " -------------------------------------------------------------------------- "
echo " -                                  Done                                  - "
echo " -------------------------------------------------------------------------- "
echo ""
