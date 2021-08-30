import { ImagePage } from './pages/item-details';

async function hasMetadata(t, field, value) {
  const selector = ImagePage.metadata.withText(field).parent();
  await t
    .expect(selector.exists).ok()
    .expect(selector.withText(value).exists).ok();
}

/**
 * Item details for 'Mallard' item, a single Tiff image
 */
fixture `Repository Item Details Page`
  .page `https://islandora-idc.traefik.me/node/49`;

test('Description', async (t) => {
  await t.expect(ImagePage.description.withText('(English)').exists).ok();
});

test('Metadata', async (t) => {
  await t.expect(ImagePage.metadata.count).eql(14);

  await hasMetadata(t, 'Alternative Title', 'Mallard Duck (English)');
  await hasMetadata(t, 'Alternative Title', 'Pato Mallard (Spanish)');
  await hasMetadata(t, 'Member of', 'Duck Collection');
  await hasMetadata(t, 'Resource Type', 'Image');
  await hasMetadata(t, 'Access Rights', 'Public digital access');
  await hasMetadata(t, 'Date Available', '2001-01-01');
  await hasMetadata(t, 'Date Created', '2001-01-01');
  await hasMetadata(t, 'Date Copyrighted', '2001-01-01');
  await hasMetadata(t, 'Date Published', '2001-01-01');
  await hasMetadata(t, 'Citable URL', '/node/49');
  await hasMetadata(t, 'Title Language', 'English');
  await hasMetadata(t, 'Description', 'a dabbling duck');
});

test('Contact modal', async (t) => {
  await t
    .expect(ImagePage.contactBtn.exists).ok()
    .expect(ImagePage.contactModal.visibility().exists).notOk()
    .click(ImagePage.contactBtn)
    .expect(ImagePage.contactModal.visibility().exists).ok()
    // Make sure collection is auto-filled
    .expect(ImagePage.contactModal.collection.value).eql('Duck Collection (42)');
});

test.skip('Download', async (t) => {});
test.skip('Export metadata', async (t) => {});