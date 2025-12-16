import codegenNativeComponent from 'react-native/Libraries/Utilities/codegenNativeComponent';
import type { ColorValue, ProcessedColorValue, ViewProps } from 'react-native';
import type {
  DirectEventHandler,
  Double,
  Int32,
  WithDefault,
} from 'react-native/Libraries/Types/CodegenTypes';
//@ts-ignore
import type { ImageSource } from 'react-native/Libraries/Image/ImageSource';

export type OnPageSelectedEventData = Readonly<{
  key: string;
}>;

export type OnTabBarMeasured = Readonly<{
  height: Int32;
}>;

export type OnNativeLayout = Readonly<{
  width: Double;
  height: Double;
}>;

export type TabViewItems = ReadonlyArray<{
  key: string;
  title: string;
  sfSymbol?: string;
  badge?: string;
  badgeBackgroundColor?: ProcessedColorValue | null;
  badgeTextColor?: ProcessedColorValue | null;
  activeTintColor?: ProcessedColorValue | null;
  hidden?: boolean;
  testID?: string;
  role?: string;
  preventsDefault?: boolean;
}>;

export interface TabViewProps extends ViewProps {
  items: TabViewItems;
  selectedPage: string;
  onPageSelected?: DirectEventHandler<OnPageSelectedEventData>;
  onTabLongPress?: DirectEventHandler<OnPageSelectedEventData>;
  onTabBarMeasured?: DirectEventHandler<OnTabBarMeasured>;
  onNativeLayout?: DirectEventHandler<OnNativeLayout>;
  icons?: ReadonlyArray<ImageSource>;
  tabBarHidden?: boolean;
  labeled?: boolean;
  sidebarAdaptable?: boolean;
  scrollEdgeAppearance?: string;
  barTintColor?: ColorValue;
  translucent?: WithDefault<boolean, true>;
  rippleColor?: ColorValue;
  activeTintColor?: ColorValue;
  inactiveTintColor?: ColorValue;
  disablePageAnimations?: boolean;
  activeIndicatorColor?: ColorValue;
  hapticFeedbackEnabled?: boolean;
  layoutDirection?: string;
  minimizeBehavior?: string;
  fontFamily?: string;
  fontWeight?: string;
  fontSize?: Int32;
}

export default codegenNativeComponent<TabViewProps>('RNCTabView', {
  interfaceOnly: true,
});
