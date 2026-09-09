# Welcome to your Expo + Native Tabs app 📱👋

This is an [Expo](https://expo.dev) project created with [`create-expo-app`](https://www.npmjs.com/package/create-expo-app). It uses [`react-native-bottom-tabs`](https://github.com/callstack/react-native-bottom-tabs) to render a real native tab bar.

## Get started

1. Install dependencies

   ```bash
   npm install
   ```

2. Build and run the app

   ```bash
   npm run android
   # or
   npm run ios
   ```

   This creates a [development build](https://docs.expo.dev/develop/development-builds/introduction/), installs it on an [Android emulator](https://docs.expo.dev/workflow/android-studio-emulator/) or [iOS simulator](https://docs.expo.dev/workflow/ios-simulator/), and starts the dev server. Once the app is installed, `npm start` is enough on its own.

> **Note:** This project requires a development build. It cannot run in [Expo Go](https://expo.dev/go), which only bundles Expo's own native modules - and the native tab bar is not one of them.

Before you build for a real device or a store, change `ios.bundleIdentifier` and `android.package` in **app.json** from `com.example.nativetabs` to your own identifiers.

You can start developing by editing the files inside the **app** directory. This project uses [file-based routing](https://docs.expo.dev/router/introduction).

## Get a fresh project

When you're ready, run:

```bash
npm run reset-project
```

This command will move the starter code to the **app-example** directory and create a blank **app** directory where you can start developing.

## Learn more

To learn more about developing your project with Expo, look at the following resources:

- [React Native Bottom Tabs documentation](https://oss.callstack.com/react-native-bottom-tabs/): Configure the native tab bar used in **app/(tabs)/\_layout.tsx**.
- [Expo documentation](https://docs.expo.dev/): Learn fundamentals, or go into advanced topics with our [guides](https://docs.expo.dev/guides).
- [Learn Expo tutorial](https://docs.expo.dev/tutorial/introduction/): Follow a step-by-step tutorial where you'll create a project that runs on Android, iOS, and the web.

## Join the community

Join our community of developers creating universal apps.

- [Expo on GitHub](https://github.com/expo/expo): View our open source platform and contribute.
- [Discord community](https://chat.expo.dev): Chat with Expo users and ask questions.
