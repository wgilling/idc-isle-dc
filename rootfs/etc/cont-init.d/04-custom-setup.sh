#!/usr/bin/with-contenv bash
set -e

source /etc/islandora/utilities.sh

function main {
    local site="default"
    # Creates database if does not already exist.
    create_database "${site}"
    # Needs to be set to do an install from existing configuration.
    drush islandora:settings:create-settings-if-missing
    drush islandora:settings:set-config-sync-directory "${DRUPAL_DEFAULT_CONFIGDIR}"
    install_site "${site}"
    # Settings like the hash / flystem can be affected by environment variables at runtime.
    update_settings_php "${site}"
    # Ensure that settings which depend on environment variables like service urls are set dynamically on startup.
    configure_islandora_module "${site}"
    configure_openseadragon "${site}"
    configure_islandora_default_module "${site}"

   
    # JHU: Fedora has been removed, so use alternate call syntax with SERVICES specified:
    #wait_for_required_services "${site}"
    wait_for_required_services "${site}" SOLR 

    # Create missing solr cores.
    create_solr_core_with_default_config "${site}"
}
main
exit 0
