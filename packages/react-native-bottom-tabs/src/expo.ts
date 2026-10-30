import { type ConfigPlugin } from '@expo/config-plugins';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);

const ConfigPlugins = require('@expo/config-plugins');

const { createRunOncePlugin, withAndroidStyles } =
  ConfigPlugins as typeof import('@expo/config-plugins');

const MATERIAL3_THEME_DYNAMIC =
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
  theme:
    | 'material2'
    | 'material3'
    | 'material3-dynamic'
    | 'material3-expressive';
};

const withMaterial3Theme: ConfigPlugin<ConfigProps> = (config, options) => {
  const theme = options?.theme;

  return withAndroidStyles(config, (stylesConfig) => {
    stylesConfig.modResults.resources.style =
      stylesConfig.modResults.resources.style?.map((style) => {
        if (style.$.name === 'AppTheme') {
          if (theme === 'material3-dynamic') {
            style.$.parent = MATERIAL3_THEME_DYNAMIC;
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

export default createRunOncePlugin(
  withMaterial3Theme,
  'react-native-bottom-tabs'
);
