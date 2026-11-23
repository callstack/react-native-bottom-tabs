import { describe, test } from './support/test';
import { expect } from 'e2e';
import { button, openExample, tab } from './support/example';

describe('native bottom tab navigator', () => {
  test('starts on the initial route', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs');

    await expect(tab(screen, 'Chat')).toBeSelected();
    await expect(button(screen, 'Press me')).toBeVisible();
  });

  test('switches tabs by their test ids', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs');

    await screen.getByTestId('articleTestID').tap();
    await expect(screen.getByText('What is Lorem Ipsum?')).toBeVisible();
    await screen.getByTestId('chatTestID').tap();

    await expect(button(screen, 'Press me')).toBeVisible();
  });

  test('stays on the current tab when a tab prevents default', async ({
    app,
    screen,
  }) => {
    await openExample(app, screen, 'Native Bottom Tabs');

    await tab(screen, 'Contacts').tap();
    // A tab that does switch, to know the tap above was handled.
    await tab(screen, 'Article').tap();
    await expect(tab(screen, 'Article')).toBeSelected();
    await tab(screen, 'Contacts').tap();

    await expect(tab(screen, 'Article')).toBeSelected();
    await expect(screen.getByText('What is Lorem Ipsum?')).toBeVisible();
  });

  test('reports a long press without switching tabs', async ({
    app,
    screen,
  }) => {
    await openExample(app, screen, 'Native Bottom Tabs');

    await tab(screen, 'Article').longPress();

    // The example renames the tab from its `tabLongPress` listener.
    await expect(tab(screen, 'New Article')).toBeVisible();
    await expect(tab(screen, 'Chat')).toBeSelected();
  });

  test('keeps test ids after a tab is renamed', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs');
    await tab(screen, 'Article').longPress();
    await expect(tab(screen, 'New Article')).toBeVisible();

    await screen.getByTestId('articleTestID').tap();

    await expect(tab(screen, 'New Article')).toBeSelected();
  });
});

describe('native bottom tab navigator with Unicode route names', () => {
  test('switches tabs', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs with Unicode keys');

    await tab(screen, 'アルバム').tap();
    await expect(tab(screen, 'アルバム')).toBeSelected();
    await tab(screen, 'Чат').tap();

    await expect(tab(screen, 'Чат')).toBeSelected();
    await expect(button(screen, 'Press me')).toBeVisible();
  });

  test('reports a long press', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs with Unicode keys');

    await tab(screen, '기사').longPress();

    await expect(tab(screen, '새 기사')).toBeVisible();
  });
});

describe('native bottom tab navigator with stacks', () => {
  test('shows the stack of the selected tab', async ({ app, screen }) => {
    await openExample(app, screen, 'Embedded stacks');
    await expect(screen.getByText('ArticleScreen')).toBeVisible();

    await tab(screen, 'Albums').tap();

    await expect(screen.getByText('AlbumsScreen')).toBeVisible();
    await expect(screen.getByText('ArticleScreen')).toBeHidden();
  });
});

describe('native bottom tab navigator with an unmounted screen', () => {
  test('removes the tab and selects another one', async ({ app, screen }) => {
    await openExample(app, screen, 'Native Bottom Tabs unmounting');

    // The example removes the selected Chat screen a second after it mounts.
    await button(screen, 'OK').tap();

    await expect(tab(screen, 'Chat')).toBeHidden();
    await expect(screen.getByRole('tab')).toHaveCount(3);
    await expect(screen.getByRole('tab', { selected: true })).toHaveCount(1);
  });
});
