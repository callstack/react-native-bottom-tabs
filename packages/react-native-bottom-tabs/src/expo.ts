import { type ConfigPlugin } from '@expo/config-plugins';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

const ConfigPlugins = require('@expo/config-plugins');
const GenerateCode = require('@expo/config-plugins/build/utils/generateCode');

const { createRunOncePlugin, withAndroidStyles, withPodfile } =
  ConfigPlugins as typeof import('@expo/config-plugins');
const { mergeContents, removeContents } =
  GenerateCode as typeof import('@expo/config-plugins/build/utils/generateCode');

const MATERIAL3_THEME_DYANMIC =
  'Theme.Material3.DynamicColors.DayNight.NoActionBar';
const MATERIAL3_THEME = 'Theme.Material3.DayNight.NoActionBar';
const MATERIAL2_THEME = 'Theme.MaterialComponents.DayNight.NoActionBar';
const MATERIAL3_EXPRESSIVE_THEME =
  'Theme.Material3Expressive.DayNight.NoActionBar';

type ConfigProps = {
  /*
   * Define theme that should be used.
   * @default 'material3'
   */
  theme?:
    | 'material2'
    | 'material3'
    | 'material3-dynamic'
    | 'material3-expressive';
  /**
   * Enable SVG tab icons on Apple platforms.
   * @default false
   */
  enableSVG?: boolean;
};

const SVG_PODFILE_TAG = 'react-native-bottom-tabs-svg';
const SVG_PODFILE_FLAG = '$RNBottomTabsEnableSVG = true';

const withMaterial3Theme: ConfigPlugin<ConfigProps> = (config, options) => {
  const theme = options?.theme;

  return withAndroidStyles(config, (stylesConfig) => {
    stylesConfig.modResults.resources.style =
      stylesConfig.modResults.resources.style?.map((style) => {
        if (style.$.name === 'AppTheme') {
          if (theme === 'material3-dynamic') {
            style.$.parent = MATERIAL3_THEME_DYANMIC;
          } else if (theme === 'material2') {
            style.$.parent = MATERIAL2_THEME;
          } else if (theme === 'material3-expressive') {
            style.$.parent = MATERIAL3_EXPRESSIVE_THEME;
          } else {
            style.$.parent = MATERIAL3_THEME;
          }
        }

        return style;
      });

    return stylesConfig;
  });
};

const withSVGSupport: ConfigPlugin<ConfigProps> = (config, options) => {
  return withPodfile(config, (podfileConfig) => {
    const contents = podfileConfig.modResults.contents;

    podfileConfig.modResults.contents = options?.enableSVG
      ? mergeContents({
          src: contents,
          newSrc: SVG_PODFILE_FLAG,
          tag: SVG_PODFILE_TAG,
          anchor: /^platform :ios/,
          offset: 1,
          comment: '#',
        }).contents
      : removeContents({
          src: contents,
          tag: SVG_PODFILE_TAG,
        }).contents;

    return podfileConfig;
  });
};

const withBottomTabs: ConfigPlugin<ConfigProps> = (config, options) => {
  config = withMaterial3Theme(config, options);
  return withSVGSupport(config, options);
};

export default createRunOncePlugin(withBottomTabs, 'react-native-bottom-tabs');
