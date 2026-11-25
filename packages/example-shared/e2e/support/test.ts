import { test as base } from '@e2e-dev/mobile';

export const test = base.extend<{}, { build: void }>({
  // e2e installs nothing on its own. This puts the target's build on each
  // device before its first test, so a run never tests a stale install.
  build: [
    async ({ device }, use) => {
      await device.installApp();
      await use();
    },
    { scope: 'worker', auto: true },
  ],
});

export const { describe, afterEach } = test;
