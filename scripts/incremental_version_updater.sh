#!/usr/bin/with-contenv bash

GH_TOKEN=${1}
if [ -z "${GH_TOKEN}" ]; then
  echo "No GitHub token provided."
  exit 1
fi

set -e
echo ""
echo ""
echo " -------------------------------------------------------------------------- "
echo " -              Running a soft update of the codebase                     - "
echo " -------------------------------------------------------------------------- "
echo ""

# Run this from the root.
# TAG='v0.7.8'
# git checkout tags/$TAG codebase/
# cp scripts/incremental_version_updater.sh codebase/incremental_version_updater.sh
# Run `make up`
# docker-compose exec -T drupal bash -lc "cd /var/www/drupal && bash /var/www/drupal/incremental_version_updater.sh"
# git reset --hard codebase/
# Then git checkout codebase/, composer install, config import, etc.

# Drupal version list was created by hand.
DRUPAL_VERSIONS=(9.4.7 9.4.6 9.4.5 9.4.4 9.4.3 9.4.2 9.4.1 9.4.0 9.3.22 9.3.21 9.3.20 9.3.19 9.3.18 9.3.17 9.3.16 9.3.15 9.3.14 9.3.13 9.3.12 9.3.11 9.3.10 9.3.9 9.3.8 9.3.7 9.3.6 9.3.5 9.3.4 9.3.3 9.3.2 9.3.0 9.2.21 9.2.20 9.2.19 9.2.18 9.2.17 9.2.16 9.2.15 9.2.14)
# 9.3.1 was unstable so it was removed.

STARTING_POINT_VERSION='9.2.13'
HIGHEST_VERSION_IN_ARRAY="${DRUPAL_VERSIONS[0]}"
CURRENT_VERSION=$(cat web/core/lib/Drupal.php | grep 'const VERSION ' | cut -d\' -f2)
echo "Current version: $CURRENT_VERSION"

apk add jq --quiet

# A recursive function to update the Drupal version number.
function update_version {
    # Github's API is rate limited. Wait a bit.
    now=$(date '+%s')
    GH=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GH_TOKEN" https://api.github.com/rate_limit | jq .rate.reset)
    REMAINING=$(curl -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $GH_TOKEN" https://api.github.com/rate_limit | jq .rate.remaining)

    if [[ "$REMAINING" -lt 1 ]]; then
        WAIT_TIME=$(( $GH - $now ))
        # if WAIT_TIME is greater than 0, wait that long.
        if [[ "$WAIT_TIME" -gt 0 ]]; then
            echo "Waiting $WAIT_TIME seconds for Github to catch up. Time: $(date --date=@$GH +%H:%M:%S)"
            sleep $WAIT_TIME
        fi
    fi

    VERSION=$(cat web/core/lib/Drupal.php | grep 'const VERSION ' | cut -d\' -f2)
    if [ "$VERSION" == "$HIGHEST_VERSION_IN_ARRAY" ]; then
        echo "Drupal is up to date. Exiting the soft update script."
        return
    fi

    if [ "$VERSION" != ${DRUPAL_VERSIONS[0]} ]; then
        # Run update here
        echo ""
        echo ""
        echo " -------------------------------------------------------------------------- "
        echo " -       Updating Drupal from $VERSION to ${DRUPAL_VERSIONS[-1]}          - "
        echo " -------------------------------------------------------------------------- "
        echo ""
        composer clearcache
        composer require drupal/core-recommended:${DRUPAL_VERSIONS[-1]} drupal/core-composer-scaffold:${DRUPAL_VERSIONS[-1]} drupal/core-project-message:${DRUPAL_VERSIONS[-1]} --update-with-all-dependencies || update_version
        wait

        if (( ${#DRUPAL_VERSIONS[@]} )); then
            unset DRUPAL_VERSIONS[$[${#DRUPAL_VERSIONS[@]}-1]]
        fi

        drush updb -y
        drush cr
        drush cron
        wait

        # Check version again
        update_version
    fi
}

# If the current version is the expected version, then run the update.
if [ "$CURRENT_VERSION" == "$STARTING_POINT_VERSION" ]; then
    echo "Updating Drupal from $(cat web/core/lib/Drupal.php | grep 'const VERSION ' | cut -d\' -f2) to $HIGHEST_VERSION_IN_ARRAY"
    composer clearcache
    COMPOSER_MEMORY_LIMIT=-1 COMPOSER_DISCARD_CHANGES=true composer install --no-interaction --no-progress --no-dev

    update_version
    bash /var/www/drupal/fix_permissions.sh /var/www/drupal/web nginx
else
    echo " - Drupal is not at the starting point version (${STARTING_POINT_VERSION}). Exiting the soft update script."
fi

apk del jq --quiet

echo ""
echo ""
echo " -------------------------------------------------------------------------- "
echo " -                                  Done                                  - "
echo " -------------------------------------------------------------------------- "
echo ""
