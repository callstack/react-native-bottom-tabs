import type { ImageSourcePropType, StyleProp, ViewStyle } from 'react-native';
import type TabView from 'react-native-bottom-tabs';
import type {
  AppleIcon,
  IconRenderingMode,
  TabRole,
} from 'react-native-bottom-tabs';

export type NavigatorRoute = {
  key: string;
  name: string;
  params?: object | undefined;
  href?: string | undefined;
};

export type NavigatorState = {
  index: number;
  routes: NavigatorRoute[];
};

export type NavigatorDescriptor<Options extends object> = {
  options: Options;
  render: () => React.ReactNode;
};

export type NavigatorActions = {
  navigate(name: string, params?: object | undefined): void;
  back(): void;
};

export type NavigatorEmitter = {
  emit(options: {
    type: string;
    target?: string;
    canPreventDefault?: boolean;
    data?: object | undefined;
  }): {
    readonly type: string;
    readonly target?: string | undefined;
    readonly defaultPrevented?: boolean;
  };
};

export type NavigatorArgs<Options extends object> = {
  state: NavigatorState;
  descriptors: Record<string, NavigatorDescriptor<Options>>;
  actions: NavigatorActions;
  emitter: NavigatorEmitter;
};

export type NativeBottomTabsEventMap = {
  /**
   * Event which fires on tapping on the tab in the tab bar.
   */
  tabPress: { data: undefined; canPreventDefault: true };
  /**
   * Event which fires on long press on tab bar.
   */
  tabLongPress: { data: undefined; canPreventDefault: false };
};

export type NativeBottomTabNavigationOptions = {
  /**
   * Title text for the screen.
   */
  title?: string;

  /**
   * Label text of the tab displayed in the navigation bar. When undefined, scene title is used.
   */
  tabBarLabel?: string;

  /**
   * Function that given { focused: boolean } returns ImageSource or AppleIcon to display in the navigation bar.
   */
  tabBarIcon?: (props: { focused: boolean }) => ImageSourcePropType | AppleIcon;

  /**
   * Rendering mode for the tab icon. Use `original` to preserve multicolor image icons.
   */
  tabBarIconRenderingMode?: IconRenderingMode;

  /**
   * Whether the tab bar item is visible. Defaults to true.
   */
  tabBarItemHidden?: boolean;

  /**
   * Badge to show on the tab icon.
   */
  tabBarBadge?: string;

  /**
   * Badge background color. (Android only)
   */
  tabBarBadgeBackgroundColor?: string;

  /**
   * Badge text color. (Android only)
   */
  tabBarBadgeTextColor?: string;

  /**
   * Whether this screens should render the first time it's accessed. Defaults to true. Set it to false if you want to render the screen on initial render.
   */
  lazy?: boolean;

  /**
   * Active tab color.
   */
  tabBarActiveTintColor?: string;

  /**
   * TestID for the tab.
   */
  tabBarButtonTestID?: string;

  /**
   * Role for the tab. (iOS only)
   */
  role?: TabRole;

  /**
   * Whether inactive screens should be suspended from re-rendering. Defaults to `false`.
   */
  freezeOnBlur?: boolean;

  /**
   * Style object for the component wrapping the screen content.
   */
  sceneStyle?: StyleProp<ViewStyle>;

  /**
   * Whether to prevent default action of the tab. Defaults to `false`.
   */
  preventsDefault?: boolean;
};

export type NativeBottomTabsDescriptorMap = Record<
  string,
  NavigatorDescriptor<NativeBottomTabNavigationOptions>
>;

export type NativeBottomTabsTabBarProps = {
  state: NavigatorState;
  descriptors: NativeBottomTabsDescriptorMap;
  actions: NavigatorActions;
  emitter: NavigatorEmitter;
};

export type NativeBottomTabsNavigatorProps = Partial<
  Omit<
    React.ComponentProps<typeof TabView>,
    | 'navigationState'
    | 'onIndexChange'
    | 'renderScene'
    | 'getLazy'
    | 'getIcon'
    | 'getIconRenderingMode'
    | 'getLabelText'
    | 'getBadge'
    | 'getBadgeBackgroundColor'
    | 'getBadgeTextColor'
    | 'onTabLongPress'
    | 'getActiveTintColor'
    | 'getTestID'
    | 'getRole'
    | 'getHidden'
    | 'tabBar'
    | 'getFreezeOnBlur'
    | 'getSceneStyle'
    | 'getPreventsDefault'
  >
> & {
  tabBar?: (props: NativeBottomTabsTabBarProps) => React.ReactNode;
  defaultTintColors?: { active?: string; inactive?: string };
  extraTabBarProps?: object;
};

export type NativeBottomTabsContentProps =
  NavigatorArgs<NativeBottomTabNavigationOptions> &
    NativeBottomTabsNavigatorProps;
