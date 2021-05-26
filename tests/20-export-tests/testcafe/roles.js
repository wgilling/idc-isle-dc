import { Role } from 'testcafe';

/**
 * Drupal administrator via local login
 */
export const adminUser = Role('https://islandora-idc-192-168-154-181.traefik.me/user/login', async t => {
    await t
        .typeText('#edit-name', 'admin')
        .typeText('#edit-pass', 'password')
        .click('#edit-submit');
});
