import type {
  ColorValue,
  ImageSourcePropType,
  StyleProp,
  ViewStyle,
} from 'react-native';
import type { SFSymbol } from 'sf-symbols-typescript';

export type IconSource = string | ImageSourcePropType;

/**
 * Weight of an SF Symbol. Accepts either a name or its numeric equivalent.
 */
export type SFSymbolWeight =
  | 'thin'
  | 'ultralight'
  | 'light'
  | 'regular'
  | 'medium'
  | 'semibold'
  | 'bold'
  | 'extrabold'
  | 'black'
  | 100
  | 200
  | 300
  | 400
  | 500
  | 600
  | 700
  | 800
  | 900;

/**
 * Scale variant of an SF Symbol.
 */
export type SFSymbolScale = 'small' | 'medium' | 'large';

/**
 * Rendering mode of an SF Symbol.
 */
export type SFSymbolRenderingMode =
  | 'monochrome'
  | 'hierarchical'
  | 'palette'
  | 'multicolor';

/**
 * How the partial state described by `variableValue` is rendered.
 */
export type SFSymbolVariableValueMode = 'automatic' | 'color' | 'draw';

/**
 * How color is applied across the layers of an SF Symbol.
 */
export type SFSymbolColorRenderingMode = 'automatic' | 'flat' | 'gradient';

/**
 * Per-layer colors of an SF Symbol.
 */
export type SFSymbolColors = {
  primary?: ColorValue;
  secondary?: ColorValue;
  tertiary?: ColorValue;
};

/**
 * An SF Symbol icon and its configuration.
 *
 * Only `sfSymbol` is required. Every other option falls back to the system
 * default for a tab bar item, which is what you want in most cases.
 *
 * @platform ios, macOS, tvOS, visionOS
 */
export type AppleIcon = {
  /**
   * The name of the SF Symbol to display, e.g. `house.fill`.
   */
  sfSymbol: SFSymbol;
  /**
   * Point size of the symbol.
   *
   * Defaults to the size the tab bar picks for the current platform.
   */
  size?: number;
  /**
   * Color of the symbol.
   *
   * Used as the tint in `monochrome` mode, and as the fallback for
   * `colors.primary` in `hierarchical` and `palette` modes. Setting it opts
   * the icon out of the tab bar's active/inactive tint colors.
   */
  color?: ColorValue;
  /**
   * Weight of the symbol.
   *
   * @default 'regular'
   */
  weight?: SFSymbolWeight;
  /**
   * Scale variant of the symbol.
   *
   * @default 'medium'
   */
  scale?: SFSymbolScale;
  /**
   * Value used to customize variable symbols, between `0` and `1`.
   *
   * Variable symbols such as `wifi` or `speaker.wave.3` have layers that
   * activate progressively to represent a magnitude. `0` renders the fewest
   * layers, `1` the full symbol. Has no effect on non-variable symbols.
   *
   * Requires iOS 16+.
   */
  variableValue?: number;
  /**
   * How the partial state described by `variableValue` is rendered.
   *
   * - `automatic`: the system chooses based on the symbol.
   * - `color`: fades inactive layers using opacity.
   * - `draw`: partially draws layers instead of fading them.
   *
   * Requires iOS 26+. Ignored on earlier versions.
   *
   * @default 'automatic'
   */
  variableValueMode?: SFSymbolVariableValueMode;
  /**
   * Rendering mode of the symbol.
   *
   * - `monochrome`: single color tint.
   * - `hierarchical`: a hierarchy derived from a single color.
   * - `palette`: explicit colors per layer, taken from `colors`.
   * - `multicolor`: the symbol's built-in multicolor scheme.
   *
   * Anything other than `monochrome` opts the icon out of the tab bar's
   * active/inactive tint colors.
   *
   * @default 'monochrome'
   */
  renderingMode?: SFSymbolRenderingMode;
  /**
   * Colors used by the non-monochrome rendering modes.
   *
   * - `hierarchical`: uses `primary` as the base color.
   * - `palette`: uses `primary`, `secondary` and `tertiary` per layer.
   * - `multicolor`: ignored.
   *
   * Falls back to `color` for `primary` when unset.
   */
  colors?: SFSymbolColors;
  /**
   * How color is applied across the symbol's layers.
   *
   * - `automatic`: the system chooses based on the symbol.
   * - `flat`: a solid color per layer.
   * - `gradient`: a gradient derived from each layer's color.
   *
   * Requires iOS 26+. Ignored on earlier versions.
   *
   * @default 'automatic'
   */
  colorRenderingMode?: SFSymbolColorRenderingMode;
};

export type TabRole = 'search';

export type IconRenderingMode = 'automatic' | 'original';

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
  iconRenderingMode?: IconRenderingMode;
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
