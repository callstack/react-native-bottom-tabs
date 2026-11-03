const { getDefaultConfig, mergeConfig } = require('@react-native/metro-config');
const path = require('path');

/**
 * Metro configuration
 * https://reactnative.dev/docs/metro
 *
 * @type {import('@react-native/metro-config').MetroConfig}
 */
const workspaceRoot = path.resolve(__dirname, '../..');
const appPath = path.relative(workspaceRoot, __dirname);

const config = {
  // Shared source and hoisted dependencies must be visible to Metro.
  watchFolders: [workspaceRoot],
  transformer: {
    // Keep shared assets beneath /assets even when ../ segments normalize.
    publicPath: `/assets/${appPath}`,
  },
  server: {
    rewriteRequestUrl(requestUrl) {
      const url = new URL(requestUrl, 'http://localhost');
      if (!url.pathname.startsWith('/assets/')) return requestUrl;

      // Metro reads asset paths relative to this app's project root.
      url.searchParams.set(
        'unstable_path',
        path.relative(appPath, url.pathname.slice('/assets/'.length))
      );
      return `/assets?${url.searchParams}`;
    },
  },
  resolver: {
    // Use this shell's React Native and patched native modules for shared code.
    nodeModulesPaths: [
      path.join(__dirname, 'node_modules'),
      path.join(workspaceRoot, 'node_modules'),
    ],
    disableHierarchicalLookup: true,
  },
};

module.exports = mergeConfig(getDefaultConfig(__dirname), config);
