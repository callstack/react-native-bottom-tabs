import Foundation

#if os(macOS)
  import AppKit
#else
  import UIKit
#endif

/// SF Symbol configuration for a single tab item icon.
///
/// Mirrors the SF Symbol options React Navigation exposes, limited to the ones
/// that describe a static symbol image. Symbol effects and content transitions
/// are intentionally absent: a tab bar item renders a still image and never
/// runs symbol animations.
///
/// Every value is optional. When one is `nil` the platform default is left
/// untouched, so an icon without options renders exactly as it did before any
/// of this configuration existed.
@objcMembers
public final class SFSymbolOptions: NSObject {
  /// Point size of the symbol.
  public var size: NSNumber?
  /// Symbol weight as a numeric value between `100` and `900`.
  public var weight: NSNumber?
  /// `small`, `medium` or `large`.
  public var scale: String?
  /// Tint color, and the fallback for `primaryColor`.
  public var color: PlatformColor?
  /// Color of the first layer.
  public var primaryColor: PlatformColor?
  /// Color of the second layer, `palette` mode only.
  public var secondaryColor: PlatformColor?
  /// Color of the third layer, `palette` mode only.
  public var tertiaryColor: PlatformColor?
  /// `monochrome`, `hierarchical`, `palette` or `multicolor`.
  public var renderingMode: String?
  /// Value between `0` and `1` for variable symbols.
  public var variableValue: NSNumber?
  /// `automatic`, `color` or `draw`. iOS 26+.
  public var variableValueMode: String?
  /// `automatic`, `flat` or `gradient`. iOS 26+.
  public var colorRenderingMode: String?

  public override init() {
    super.init()
  }

  /// Builds options from the dictionary the Fabric component view assembles.
  ///
  /// Returns `nil` for a missing dictionary so callers can keep the untouched
  /// default rendering path.
  public convenience init?(dictionary: NSDictionary?) {
    guard let dictionary else { return nil }

    self.init()

    size = dictionary["size"] as? NSNumber
    weight = dictionary["weight"] as? NSNumber
    scale = dictionary["scale"] as? String
    color = dictionary["color"] as? PlatformColor
    primaryColor = dictionary["primaryColor"] as? PlatformColor
    secondaryColor = dictionary["secondaryColor"] as? PlatformColor
    tertiaryColor = dictionary["tertiaryColor"] as? PlatformColor
    renderingMode = dictionary["renderingMode"] as? String
    variableValue = dictionary["variableValue"] as? NSNumber
    variableValueMode = dictionary["variableValueMode"] as? String
    colorRenderingMode = dictionary["colorRenderingMode"] as? String
  }
}

extension SFSymbolOptions {
  /// The color the first layer should use, falling back to the plain tint.
  var effectivePrimaryColor: PlatformColor? {
    primaryColor ?? color
  }

  /// Whether any color at all was configured.
  var hasExplicitColors: Bool {
    color != nil || primaryColor != nil || secondaryColor != nil || tertiaryColor != nil
  }

  /// Whether the resulting image carries its own colors and must therefore
  /// bypass the tab bar's active/inactive tint.
  ///
  /// A layered rendering mode without any color of its own stays tintable, so
  /// picking `hierarchical` alone still follows the tab bar's active and
  /// inactive colors rather than falling back to black.
  var preservesOwnColors: Bool {
    switch renderingMode {
    case "multicolor":
      return true
    case "hierarchical", "palette":
      return hasExplicitColors
    default:
      return effectivePrimaryColor != nil
    }
  }

  /// Whether anything at all was configured.
  var isEmpty: Bool {
    size == nil
      && weight == nil
      && scale == nil
      && color == nil
      && primaryColor == nil
      && secondaryColor == nil
      && tertiaryColor == nil
      && renderingMode == nil
      && variableValue == nil
      && variableValueMode == nil
      && colorRenderingMode == nil
  }

  /// The variable value clamped to the `0...1` range the symbol APIs accept.
  var clampedVariableValue: Double? {
    guard let variableValue else { return nil }
    return min(max(variableValue.doubleValue, 0), 1)
  }
}

// MARK: - Image building

#if os(macOS)
  extension SFSymbolOptions {
    /// Builds a configured symbol image, or `nil` when the symbol is unknown.
    static func makeImage(named name: String, options: SFSymbolOptions?) -> NSImage? {
      guard !name.isEmpty else { return nil }

      var image: NSImage?

      if #available(macOS 13.0, *), let variableValue = options?.clampedVariableValue {
        image = NSImage(
          systemSymbolName: name,
          variableValue: variableValue,
          accessibilityDescription: nil
        )
      }

      if image == nil {
        image = NSImage(systemSymbolName: name, accessibilityDescription: nil)
      }

      guard let image else { return nil }
      guard let options, !options.isEmpty else { return image }
      // `NSImage.SymbolConfiguration.applying(_:)` landed in macOS 12, and
      // combining configurations is what makes the options composable. On
      // macOS 11 the symbol renders with the platform defaults instead.
      guard #available(macOS 12.0, *) else { return image }

      guard let configuration = options.symbolConfiguration() else { return image }

      let configured = image.withSymbolConfiguration(configuration) ?? image
      // A template image is recolored by the tab bar, discarding the symbol's
      // own colors, so a colored symbol has to opt out of templating.
      configured.isTemplate = !options.preservesOwnColors

      return configured
    }

    @available(macOS 12.0, *)
    private func symbolConfiguration() -> NSImage.SymbolConfiguration? {
      var configuration: NSImage.SymbolConfiguration?

      func apply(_ next: NSImage.SymbolConfiguration) {
        configuration = configuration?.applying(next) ?? next
      }

      if let size = size?.doubleValue, size > 0 {
        apply(
          NSImage.SymbolConfiguration(
            pointSize: CGFloat(size),
            weight: Self.symbolWeight(from: weight)
          )
        )
      } else if weight != nil {
        apply(NSImage.SymbolConfiguration(pointSize: NSFont.systemFontSize, weight: Self.symbolWeight(from: weight)))
      }

      if let scale, let symbolScale = Self.symbolScale(from: scale) {
        apply(NSImage.SymbolConfiguration(scale: symbolScale))
      }

      switch renderingMode {
      case "hierarchical":
        if let primary = effectivePrimaryColor {
          apply(NSImage.SymbolConfiguration(hierarchicalColor: primary))
        }
      case "palette":
        let paletteColors = [effectivePrimaryColor, secondaryColor, tertiaryColor]
          .compactMap { $0 }
        if !paletteColors.isEmpty {
          apply(NSImage.SymbolConfiguration(paletteColors: paletteColors))
        }
      case "multicolor":
        apply(NSImage.SymbolConfiguration.preferringMulticolor())
      default:
        // A tab item cannot carry a tint of its own, so a monochrome symbol
        // with an explicit color is colored through a single-color palette.
        if let primary = effectivePrimaryColor {
          apply(NSImage.SymbolConfiguration(paletteColors: [primary]))
        }
      }

      return configuration
    }

    @available(macOS 12.0, *)
    private static func symbolWeight(from value: NSNumber?) -> NSFont.Weight {
      switch value?.intValue {
      case 100: return .thin
      case 200: return .ultraLight
      case 300: return .light
      case 400: return .regular
      case 500: return .medium
      case 600: return .semibold
      case 700: return .bold
      case 800: return .heavy
      case 900: return .black
      default: return .regular
      }
    }

    @available(macOS 12.0, *)
    private static func symbolScale(from value: String) -> NSImage.SymbolScale? {
      switch value {
      case "small": return .small
      case "medium": return .medium
      case "large": return .large
      default: return nil
      }
    }
  }
#else
  extension SFSymbolOptions {
    /// Builds a configured symbol image, or `nil` when the symbol is unknown.
    ///
    /// Falls back to a symbol from the app's asset catalog, so custom symbols
    /// shipped alongside SF Symbols keep working.
    static func makeImage(named name: String, options: SFSymbolOptions?) -> UIImage? {
      guard !name.isEmpty else { return nil }

      let configuration = options?.symbolConfiguration()

      guard
        let image = baseImage(
          named: name,
          variableValue: options?.clampedVariableValue,
          configuration: configuration
        )
      else { return nil }

      guard let options else { return image }

      return options.tinted(image)
    }

    private static func baseImage(
      named name: String,
      variableValue: Double?,
      configuration: UIImage.SymbolConfiguration?
    ) -> UIImage? {
      if let variableValue, #available(iOS 16.0, tvOS 16.0, *) {
        if let image = UIImage(
          systemName: name,
          variableValue: variableValue,
          configuration: configuration
        ) {
          return image
        }
      }

      guard let configuration else {
        return UIImage(systemName: name) ?? UIImage(named: name)
      }

      return UIImage(systemName: name, withConfiguration: configuration)
        ?? UIImage(named: name)?.applyingSymbolConfiguration(configuration)
    }

    /// Settles the final colors and rendering mode of the image.
    ///
    /// A tab bar templates whatever image it is handed, which throws away the
    /// symbol's own colors, so a colored symbol has to opt out with
    /// `.alwaysOriginal` the same way an `original` image icon does. A
    /// monochrome symbol has no layer colors to keep, so its color is baked in
    /// as a flat tint instead.
    private func tinted(_ image: UIImage) -> UIImage {
      guard preservesOwnColors else { return image }

      switch renderingMode {
      case "multicolor":
        return Self.flattened(image)
      case "hierarchical", "palette":
        if #available(iOS 15.0, tvOS 15.0, *) {
          return Self.flattened(image)
        }
        // Layered color APIs do not exist before iOS 15, so the primary color
        // is applied as a flat tint as the closest approximation.
        guard let color = effectivePrimaryColor else { return image }
        return Self.flattened(image.withTintColor(color, renderingMode: .alwaysOriginal))
      default:
        guard let color = effectivePrimaryColor else { return image }
        return Self.flattened(image.withTintColor(color, renderingMode: .alwaysOriginal))
      }
    }

    /// Draws the symbol into a plain bitmap that keeps the colors it was
    /// configured with.
    ///
    /// Colors have to survive two separate attempts to recolor them. A tab bar
    /// templates the image it is handed, and SwiftUI applies its own
    /// `symbolRenderingMode` to anything it recognises as a symbol, which
    /// flattens the layered modes back to a single tint. Rasterizing drops the
    /// symbol identity, so neither applies, and `.alwaysOriginal` keeps the
    /// result untinted.
    private static func flattened(_ image: UIImage) -> UIImage {
      let format = UIGraphicsImageRendererFormat()
      format.scale = image.scale
      format.opaque = false

      let rendered = UIGraphicsImageRenderer(size: image.size, format: format).image { _ in
        image.draw(in: CGRect(origin: .zero, size: image.size))
      }

      return rendered.withRenderingMode(.alwaysOriginal)
    }

    /// Translates the options into a `UIImage.SymbolConfiguration`.
    ///
    /// Returns `nil` when nothing was configured, so the caller can request an
    /// unconfigured image and keep the tab bar's own sizing.
    func symbolConfiguration() -> UIImage.SymbolConfiguration? {
      guard !isEmpty else { return nil }

      var configuration: UIImage.SymbolConfiguration?

      func apply(_ next: UIImage.SymbolConfiguration) {
        configuration = configuration?.applying(next) ?? next
      }

      if let size = size?.doubleValue, size > 0 {
        apply(UIImage.SymbolConfiguration(pointSize: CGFloat(size)))
      }

      if let weight {
        apply(UIImage.SymbolConfiguration(weight: Self.symbolWeight(from: weight)))
      }

      if let scale, let symbolScale = Self.symbolScale(from: scale) {
        apply(UIImage.SymbolConfiguration(scale: symbolScale))
      }

      #if compiler(>=6.2)
        if #available(iOS 26.0, tvOS 26.0, *) {
          if let variableValueMode,
            let mode = Self.symbolVariableValueMode(from: variableValueMode) {
            apply(UIImage.SymbolConfiguration(variableValueMode: mode))
          }

          if let colorRenderingMode,
            let mode = Self.symbolColorRenderingMode(from: colorRenderingMode) {
            apply(UIImage.SymbolConfiguration(colorRenderingMode: mode))
          }
        }
      #endif

      switch renderingMode {
      case "hierarchical":
        if let primary = effectivePrimaryColor {
          if #available(iOS 15.0, tvOS 15.0, *) {
            apply(UIImage.SymbolConfiguration(hierarchicalColor: primary))
          }
        }
      case "palette":
        let paletteColors = [effectivePrimaryColor, secondaryColor, tertiaryColor]
          .compactMap { $0 }
        if !paletteColors.isEmpty, #available(iOS 15.0, tvOS 15.0, *) {
          apply(UIImage.SymbolConfiguration(paletteColors: paletteColors))
        }
      case "multicolor":
        if #available(iOS 15.0, tvOS 15.0, *) {
          apply(UIImage.SymbolConfiguration.preferringMulticolor())
        }
      default:
        break
      }

      return configuration
    }

    private static func symbolWeight(from value: NSNumber) -> UIImage.SymbolWeight {
      switch value.intValue {
      case 100: return .thin
      case 200: return .ultraLight
      case 300: return .light
      case 400: return .regular
      case 500: return .medium
      case 600: return .semibold
      case 700: return .bold
      case 800: return .heavy
      case 900: return .black
      default: return .unspecified
      }
    }

    private static func symbolScale(from value: String) -> UIImage.SymbolScale? {
      switch value {
      case "small": return .small
      case "medium": return .medium
      case "large": return .large
      default: return nil
      }
    }

    #if compiler(>=6.2)
      @available(iOS 26.0, tvOS 26.0, *)
      private static func symbolVariableValueMode(from value: String)
        -> UIImage.SymbolVariableValueMode? {
        switch value {
        case "automatic": return .automatic
        case "color": return .color
        case "draw": return .draw
        default: return nil
        }
      }

      @available(iOS 26.0, tvOS 26.0, *)
      private static func symbolColorRenderingMode(from value: String)
        -> UIImage.SymbolColorRenderingMode? {
        switch value {
        case "automatic": return .automatic
        case "flat": return .flat
        case "gradient": return .gradient
        default: return nil
        }
      }
    #endif
  }
#endif
