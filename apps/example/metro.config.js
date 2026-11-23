const { makeMetroConfig } = require('@rnx-kit/metro-config');
const path = require('path');

const root = path.resolve(__dirname, '../..');

const extraConfig = {
  watchFolders: [root],
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: true,
      },
    }),
  },
  resolver: {
    unstable_enableSymlinks: true,
    // Shared code and the workspace packages each have their own copy of some
    // dependencies. Resolve everything from this app so the bundle has one.
    nodeModulesPaths: [
      path.join(__dirname, 'node_modules'),
      path.join(root, 'node_modules'),
    ],
    disableHierarchicalLookup: true,
  },
};

const metroConfig = makeMetroConfig(extraConfig);
const rewriteRequestUrl = metroConfig.server.rewriteRequestUrl;

metroConfig.server.rewriteRequestUrl = (requestUrl) => {
  const rewrittenUrl = rewriteRequestUrl(requestUrl);
  if (!rewrittenUrl.startsWith('/assets/')) return rewrittenUrl;

  // rnx-kit restores @@ to ../ for assets outside this app. Keep those paths
  // in Metro's asset query so URL normalization cannot escape /assets/.
  const [assetPath, query = ''] = rewrittenUrl.slice('/assets/'.length).split('?');
  if (!assetPath.split('/').includes('..')) return rewrittenUrl;

  const params = new URLSearchParams(query);
  params.set('unstable_path', assetPath);
  return `/assets?${params}`;
};

module.exports = metroConfig;
