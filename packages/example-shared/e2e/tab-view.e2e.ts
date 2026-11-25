import { describe, test } from './support/test';
import { expect } from 'e2e';
import { button, openExample, tab } from './support/example';

describe('TabView', () => {
  test('starts on the tab at the initial index', async ({ app, screen }) => {
    await openExample(app, screen, 'Three Tabs');

    await expect(tab(screen, 'Albums')).toBeSelected();
  });

  test('shows the scene of the tapped tab', async ({ app, screen }) => {
    await openExample(app, screen, 'Four Tabs');

    await tab(screen, 'Contacts').tap();

    await expect(tab(screen, 'Contacts')).toBeSelected();
    await expect(screen.getByText('Currently Playing Song')).toBeVisible();
  });

  test('switches tabs when a scene calls jumpTo', async ({ app, screen }) => {
    await openExample(app, screen, 'Four Tabs');

    await button(screen, 'Go to Albums').tap();

    await expect(tab(screen, 'Albums')).toBeSelected();
    await expect(button(screen, 'Go to Albums')).toBeHidden();
  });

  test('leaves a hidden tab out of the tab bar', async ({ app, screen }) => {
    await openExample(app, screen, 'Four Tabs - With Hidden Tab');

    await expect(tab(screen, 'Article')).toBeSelected();
    await expect(screen.getByRole('tab')).toHaveCount(3);
    await expect(tab(screen, 'Albums')).toBeHidden();
  });

  test('shows the tab bar again after a screen that hides it', async ({
    app,
    screen,
  }) => {
    await openExample(app, screen, 'Five Tabs');
    await tab(screen, 'Fifth').tap();
    await tab(screen, 'Article').tap();

    await button(screen, 'Open hidden tab bar screen').tap();
    await expect(screen.getByRole('tab')).toHaveCount(0);
    await button(screen, 'Go back').tap();

    await expect(screen.getByRole('tab')).toHaveCount(5);
    await expect(tab(screen, 'Article')).toBeSelected();
  });

  test('shows six tabs on Android', async ({ app, screen, platform }) => {
    test.skip(platform !== 'android', 'iOS has a More tab instead');
    await openExample(app, screen, 'Six Tabs');

    await tab(screen, 'Sixth').tap();

    await expect(screen.getByRole('tab')).toHaveCount(6);
    await expect(tab(screen, 'Sixth')).toBeSelected();
  });

  test('moves the tabs past the fourth into a More tab on iOS', async ({
    app,
    screen,
    platform,
  }) => {
    test.skip(platform !== 'ios', 'Android shows every tab');
    await openExample(app, screen, 'Six Tabs');

    await tab(screen, 'More').tap();
    await screen.getByText('Sixth').tap();

    // The scene of the sixth tab opens on top of the More list.
    await expect(screen.getByRole('button', 'More')).toBeVisible();
    await expect(tab(screen, 'More')).toBeSelected();
  });

  test('puts the badge in the name of a tab on Android', async ({
    app,
    screen,
    platform,
  }) => {
    test.skip(
      platform !== 'android',
      'iOS keeps the badge out of the tab name'
    );
    await openExample(app, screen, 'Four Tabs');

    await expect(tab(screen, 'Albums')).toHaveAccessibleName('Albums, 5');
  });

  test('renders a custom tab bar in place of the native one', async ({
    app,
    screen,
  }) => {
    await openExample(app, screen, 'Custom tabBar');
    await expect(screen.getByRole('tab')).toHaveCount(0);

    await screen.getByLabel('Albums').tap();

    // The scene shows the title of its route, next to the one in the tab bar.
    await expect(screen.getByText('Albums')).toHaveCount(2);
    await expect(screen.getByText('Article')).toHaveCount(1);
  });

  test('renders the bottom accessory view on iOS', async ({
    app,
    screen,
    platform,
  }) => {
    test.skip(platform !== 'ios', 'Android has no bottom accessory view');
    await openExample(app, screen, 'Bottom Accessory View');

    await expect(screen.getByText(/^Placement: expanded\./)).toBeVisible();
  });
});
