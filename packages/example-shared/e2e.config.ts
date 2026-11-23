import type { E2EConfig } from 'e2e';
import { mobile } from '@e2e-dev/mobile';

// A simulator or emulator by name or id. Without it, every booted device of
// the platform is used.
const device = process.env.E2E_DEVICE;

// The builds of the `e2e:build:ios` and `e2e:build:android` scripts.
const iosBuild = 'ios/build/e2e/Build/Products/Release-iphonesimulator';

export default {
  tests: 'e2e/**/*.e2e.ts',
  targets: [
    {
      name: 'ios',
      engine: mobile({ platform: 'ios', device }),
      app: {
        bundleId: 'bottomtabs.example',
        appPath: `../../apps/example/${iosBuild}/ReactTestApp.app`,
      },
    },
    {
      name: 'android',
      engine: mobile({ platform: 'android', device }),
      app: {
        bundleId: 'bottomtabs.example',
        appPath:
          '../../apps/example/android/app/build/outputs/apk/release/app-release.apk',
      },
    },
    {
      name: 'ios-swiftpm',
      engine: mobile({ platform: 'ios', device }),
      app: {
        bundleId: 'bottomtabs.exampleswiftpm',
        appPath: `../../apps/example-swiftpm/${iosBuild}/ExampleSwiftPM.app`,
      },
    },
  ],
} satisfies E2EConfig;
