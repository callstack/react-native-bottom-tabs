# Contributing

Contributions are always welcome, no matter how large or small!

We want this community to be friendly and respectful to each other. Please follow it in all your interactions with the project. Before contributing, please read the [code of conduct](./CODE_OF_CONDUCT.md).

## Development workflow

This project is a monorepo managed using [Yarn workspaces](https://yarnpkg.com/features/workspaces). It contains the following packages:

- The core library package in the `packages` directory
- React Native example app in `apps/example`

To get started with the project, run `yarn` in the root directory to install the required dependencies for each package:

```sh
yarn
```

> Since the project relies on Yarn workspaces, you cannot use [`npm`](https://github.com/npm/cli) for development.

The example apps in the `apps` directory demonstrate usage of the library. You need to run one of them to test any changes you make.

They are configured to use the local version of the library, so any changes you make to the library's source code will be reflected in the example apps. Changes to the library's JavaScript code will be reflected without a rebuild, but native code changes will require a rebuild of the example app.

If you want to use Android Studio or XCode to edit the native code, you can open the `apps/example/android` or `apps/example/ios` directories respectively in those editors.

You can use various commands from the root directory to work with the project.

To start the packager for the React Native example:

```sh
yarn workspace react-native-bottom-tabs-example start
```

To run the React Native example app on Android:

```sh
yarn workspace react-native-bottom-tabs-example android
```

To run the React Native example app on iOS, you need to install cocoapods.

```sh
cd apps/example/ios
pod install
cd -
yarn ios
```

Make sure your code passes TypeScript and ESLint. Run the following to verify:

```sh
yarn typecheck
yarn lint
```

To fix formatting errors, run the following:

```sh
yarn lint --fix
```

Remember to add tests for your change if possible. Run the unit tests by:

```sh
yarn test
```

### Commit message convention

We follow the [conventional commits specification](https://www.conventionalcommits.org/en) for our commit messages:

- `fix`: bug fixes, e.g. fix crash due to deprecated method.
- `feat`: new features, e.g. add new method to the module.
- `refactor`: code refactor, e.g. migrate from class components to hooks.
- `docs`: changes into documentation, e.g. add usage example for the module..
- `test`: adding or updating tests, e.g. add integration tests using detox.
- `chore`: tooling changes, e.g. change CI config.

Our pre-commit hooks verify that your commit message matches this format when committing.

### Linting and tests

[ESLint](https://eslint.org/), [Prettier](https://prettier.io/), [TypeScript](https://www.typescriptlang.org/)

We use [TypeScript](https://www.typescriptlang.org/) for type checking, [ESLint](https://eslint.org/) with [Prettier](https://prettier.io/) for linting and formatting the code, and [Jest](https://jestjs.io/) for testing.

Our pre-commit hooks verify that the linter and tests pass when committing.

### Changesets

We use [changesets](https://github.com/changesets/changesets) to make it easier to publish new versions. It handles common tasks like bumping version based on semver, creating tags and releases etc.

If your changes impact packages that need to be published, you need to create a changeset for those changes. You can do that by running the following command:

```sh
yarn changeset
```

Changes to example apps or docs don't require a changeset.

### Publishing to npm

After merging a PR to `main`, if it included a changeset, the CI workflow will automatically create another `chore: version packages` PR bumping the version of the impacted packages. Merging this PR will trigger the release workflow, which will automatically publish the new versions to npm.

### Sending a pull request

> **Working on your first pull request?** You can learn how from this _free_ series: [How to Contribute to an Open Source Project on GitHub](https://app.egghead.io/playlists/how-to-contribute-to-an-open-source-project-on-github).

When you're sending a pull request:

- Prefer small pull requests focused on one change.
- Verify that linters and tests are passing.
- Review the documentation to make sure it looks good.
- Follow the pull request template when opening a pull request.
- For pull requests that change the API or implementation, discuss with maintainers first by opening an issue.
