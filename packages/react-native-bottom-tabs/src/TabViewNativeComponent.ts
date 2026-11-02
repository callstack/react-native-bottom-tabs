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

/**
 * Flattened SF Symbol configuration sent to the native side.
 *
 * Unset values are encoded with sentinels rather than omitted, so the native
 * side can tell "not configured" apart from a legitimate zero:
 * `0` for `size` and `weight`, `-1` for `variableValue`, `''` for strings.
 */
export type SFSymbolOptions = Readonly<{
  size: Double;
  weight: Int32;
  scale: string;
  color?: ProcessedColorValue | null;
  primaryColor?: ProcessedColorValue | null;
  secondaryColor?: ProcessedColorValue | null;
  tertiaryColor?: ProcessedColorValue | null;
  renderingMode: string;
  variableValue: Double;
  variableValueMode: string;
  colorRenderingMode: string;
}>;

export type TabViewItems = ReadonlyArray<{
  key: string;
  title: string;
  sfSymbol?: string;
  sfSymbolOptions?: SFSymbolOptions;
  focusedSfSymbol?: string;
  focusedSfSymbolOptions?: SFSymbolOptions;
  badge?: string;
  badgeBackgroundColor?: ProcessedColorValue | null;
  badgeTextColor?: ProcessedColorValue | null;
  activeTintColor?: ProcessedColorValue | null;
  iconRenderingMode?: string;
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
  focusedIcons?: ReadonlyArray<ImageSource>;
  tabBarHidden?: boolean;
  labeled?: boolean;
  sidebarAdaptable?: boolean;
  scrollEdgeAppearance?: string;
  barTintColor?: ColorValue;
  translucent?: WithDefault<boolean, true>;
  rippleColor?: ColorValue;
  activeTintColor?: ColorValue;
  inactiveTintColor?: ColorValue;
  experimentalBakedTintColors?: WithDefault<boolean, false>;
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
