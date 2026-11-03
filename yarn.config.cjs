// Shared runtime dependencies stay explicit in each example's package.json.
// Edit versions here, then run yarn constraints --fix and yarn install.
const versions = {
  '@bottom-tabs/react-navigation': '*',
  '@react-navigation/bottom-tabs': '^7.15.9',
  '@react-navigation/devtools': '^7.0.44',
  '@react-navigation/native': '^7.3.0',
  '@react-navigation/native-stack': '^7.14.11',
  '@react-navigation/stack': '^7.8.10',
  'color': '^5.0.0',
  'react': '^19.2.3',
  'react-native': '^0.87.1',
  'react-native-bottom-tabs': '*',
  'react-native-edge-to-edge': '^1.7.0',
  'react-native-gesture-handler': '^3.2.1',
  'react-native-paper': '^5.14.5',
  'react-native-safe-area-context': '^5.9.1',
  'react-native-screens': '^4.27.0',
  'react-native-vector-icons': '^10.2.0',
  'react-native-worklets': '^0.12.1',
};

// Patch updates must be checked against the corresponding upstream release.
const swiftpmOverrides = {
  'react-native-gesture-handler':
    'patch:react-native-gesture-handler@npm%3A3.2.1#~/.yarn/patches/react-native-gesture-handler-npm-3.2.1-73a74f5c79.patch',
  'react-native-safe-area-context':
    'patch:react-native-safe-area-context@npm%3A5.9.1#~/.yarn/patches/react-native-safe-area-context-npm-5.9.1-b51fb9c5f7.patch',
  'react-native-screens':
    'patch:react-native-screens@npm%3A4.27.0#~/.yarn/patches/react-native-screens-npm-4.27.0-78335f53c6.patch',
  'react-native-vector-icons':
    'patch:react-native-vector-icons@npm%3A10.2.0#~/.yarn/patches/react-native-vector-icons-npm-10.2.0-e1aad1f85c.patch',
  'react-native-worklets':
    'patch:react-native-worklets@npm%3A0.12.1#~/.yarn/patches/react-native-worklets-npm-0.12.1-aa8a1b2670.patch',
};

const examples = new Set([
  'apps/example',
  'apps/example-swiftpm',
  'packages/example-shared',
]);

module.exports = {
  async constraints({ Yarn }) {
    for (const workspace of Yarn.workspaces()) {
      if (!examples.has(workspace.cwd)) continue;

      const dependencies = {
        ...versions,
        ...(workspace.cwd === 'apps/example-swiftpm' ? swiftpmOverrides : {}),
      };

      for (const [name, version] of Object.entries(dependencies)) {
        workspace.set(['dependencies', name], version);
      }
    }
  },
};
