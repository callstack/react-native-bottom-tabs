const project = (() => {
  try {
    const { configureProjects } = require('react-native-test-app');
    return configureProjects({
      android: {
        sourceDir: 'android',
      },
      ios: {
        sourceDir: 'ios',
        // Letting the RN CLI auto-install pods fails because it expects a Gemfile
        // next to the app, which this workspace doesn't use.
        automaticPodsInstallation: false,
      },
    });
  } catch (_) {
    return undefined;
  }
})();

module.exports = {
  ...(project ? { project } : undefined),
};
