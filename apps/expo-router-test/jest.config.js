const fs = require('node:fs');
const path = require('node:path');

const preset = require('jest-expo/jest-preset');

const TRANSFORM_ALSO = ['color'];
const PROJECT_COPIES = ['react', 'react-dom'];

const reactNavigationScope = path.dirname(
  path.dirname(require.resolve('@react-navigation/native/package.json'))
);

const reactNavigationCopies = fs
  .readdirSync(reactNavigationScope)
  .map((name) => [
    `^@react-navigation/${name}($|/.*)`,
    `${reactNavigationScope}/${name}$1`,
  ]);

module.exports = {
  preset: 'jest-expo',

  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],

  moduleNameMapper: {
    ...Object.fromEntries(
      PROJECT_COPIES.map((name) => [
        `^${name}($|/.*)`,
        path.dirname(require.resolve(`${name}/package.json`)) + '$1',
      ])
    ),
    ...Object.fromEntries(reactNavigationCopies),
  },

  transformIgnorePatterns: preset.transformIgnorePatterns.map((pattern) =>
    pattern.startsWith('/node_modules/(?!(')
      ? pattern.replace(/\)\)$/, `|${TRANSFORM_ALSO.join('|')}))`)
      : pattern
  ),
};
