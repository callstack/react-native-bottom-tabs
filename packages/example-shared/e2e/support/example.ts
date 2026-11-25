import { expect } from 'e2e';
import type { App, Locator, Screen } from 'e2e';

const escape = (text: string) => text.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

export async function openExample(app: App, screen: Screen, name: string) {
  await app.open();
  // The list renders a moment after launch. Scrolling before it does skips rows.
  await expect(screen.getByTestId('Three Tabs')).toBeVisible({
    timeout: 30_000,
  });
  const example = screen.getByTestId(name);
  await screen.scrollUntilVisible(example);
  await example.tap();
}

// Android appends the badge to the tab's name: "Article, 10".
export function tab(screen: Screen, title: string): Locator {
  return screen.getByRole('tab', new RegExp(`^${escape(title)}(,|$)`));
}

// Android shows the title of a React Native `Button` in upper case.
export function button(screen: Screen, title: string): Locator {
  return screen.getByRole('button', new RegExp(`^${escape(title)}$`, 'i'));
}
