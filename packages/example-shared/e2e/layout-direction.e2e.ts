import { afterEach, describe, test } from './support/test';
import { expect } from 'e2e';
import { openExample, tab } from './support/example';

describe('layoutDirection', () => {
  // The example forces the whole app into a right-to-left layout, which
  // outlives the launch.
  afterEach(async ({ app }) => {
    await app.clearState();
  });

  test('lays the tabs out from right to left', async ({ app, screen }) => {
    await openExample(app, screen, 'Four Tabs - RTL');

    const articles = await tab(screen, 'المقالات').boundingBox();
    const albums = await tab(screen, 'البومات').boundingBox();

    // Articles is the first tab.
    expect(articles?.x).toBeGreaterThan(albums?.x ?? Infinity);
  });
});
