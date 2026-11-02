const path = require('path');
const fs = require('fs');

const packages = path.resolve(__dirname, '..', '..', 'packages');

/** @type {import('@babel/core').TransformOptions} */
module.exports = function (api) {
  api.cache(true);

  const alias = Object.fromEntries(
    fs
      .readdirSync(packages)
      .filter((name) => !name.startsWith('.'))
      .map((name) => {
        const pak = require(`../../packages/${name}/package.json`);

        if (pak.source == null) {
          return null;
        }

        return [pak.name, path.resolve(packages, name, pak.source)];
      })
      .filter(Boolean)
  );

  return {
    presets: ['module:@react-native/babel-preset'],
    plugins: ['react-native-worklets/plugin'],
    overrides: [
      {
        exclude: /\/node_modules\//,
        plugins: [
          [
            'module-resolver',
            {
              extensions: ['.tsx', '.ts', '.js', '.json'],
              alias,
            },
          ],
        ],
      },
    ],
  };
};
