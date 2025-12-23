import type { ImageSourcePropType, StyleProp, ViewStyle } from 'react-native';
import type { SFSymbol } from 'sf-symbols-typescript';

export type IconSource = string | ImageSourcePropType;

export type AppleIcon = { sfSymbol: SFSymbol };

export type TabRole = 'search';

export type LayoutDirection = 'ltr' | 'rtl' | 'locale';

export type BaseRoute = {
  key: string;
  title?: string;
  badge?: string;
  badgeBackgroundColor?: string;
  badgeTextColor?: string;
  lazy?: boolean;
  focusedIcon?: ImageSourcePropType | AppleIcon;
  unfocusedIcon?: ImageSourcePropType | AppleIcon;
  activeTintColor?: string;
  hidden?: boolean;
  testID?: string;
  role?: TabRole;
  freezeOnBlur?: boolean;
  style?: StyleProp<ViewStyle>;
  preventsDefault?: boolean;
};

export type NavigationState<Route extends BaseRoute> = {
  index: number;
  routes: Route[];
};
