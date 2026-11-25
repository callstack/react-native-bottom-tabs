import { describe, test } from './support/test';
import { expect } from 'e2e';
import { button, openExample, tab } from './support/example';

describe('tabBarHidden', () => {
  for (const example of [
    'Tab Bar Hidden',
    'Native Bottom Tabs with tabBarHidden',
  ]) {
    test(`hides and shows the tab bar in ${example}`, async ({
      app,
      screen,
    }) => {
      await openExample(app, screen, example);
      await expect(screen.getByRole('tab')).toHaveCount(3);

      await button(screen, 'Hide Tab Bar').tap();
      await expect(screen.getByRole('tab')).toHaveCount(0);
      await button(screen, 'Show Tab Bar').tap();

      await expect(screen.getByRole('tab')).toHaveCount(3);
      await expect(tab(screen, 'Article')).toBeSelected();
    });
  }
});
