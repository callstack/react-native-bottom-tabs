import SwiftUI

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var sfSymbolOptions: SFSymbolOptions?
  var labeled: Bool?
  var iconRenderingMode: String?

  var body: some View {
    if let icon {
#if os(macOS)
      Image(nsImage: icon)
#else
      Image(uiImage: renderedIcon(icon))
#endif
    } else if let sfSymbol, !sfSymbol.isEmpty {
      symbolImage(sfSymbol)
    }
    if labeled != false {
      Text(title ?? "")
    }
  }

  /// Renders the SF Symbol.
  ///
  /// Without any configuration this stays on `Image(systemName:)` so the
  /// symbol keeps the tab bar's own sizing and tinting. Once options are set,
  /// the symbol is built as a configured image instead, and opts out of the
  /// tab bar tint when it carries colors of its own.
  @ViewBuilder
  private func symbolImage(_ sfSymbol: String) -> some View {
    if let sfSymbolOptions, !sfSymbolOptions.isEmpty,
      let image = SFSymbolOptions.makeImage(named: sfSymbol, options: sfSymbolOptions) {
#if os(macOS)
      Image(nsImage: image)
        .symbolRenderingModeIfNeeded(preservesOwnColors: sfSymbolOptions.preservesOwnColors)
#else
      Image(uiImage: image)
        .symbolRenderingModeIfNeeded(preservesOwnColors: sfSymbolOptions.preservesOwnColors)
#endif
    } else {
      Image(systemName: sfSymbol)
        .noneSymbolVariant()
    }
  }

#if !os(macOS)
  private var preservesOriginalIconColors: Bool {
    iconRenderingMode == "original"
  }

  private func renderedIcon(_ icon: UIImage) -> UIImage {
    preservesOriginalIconColors ? icon.withRenderingMode(.alwaysOriginal) : icon
  }
#endif
}

extension Image {
  /// Keeps the symbol's own colors when a non-monochrome rendering mode or an
  /// explicit color was configured, otherwise leaves templating to the tab bar.
  @ViewBuilder
  func symbolRenderingModeIfNeeded(preservesOwnColors: Bool) -> some View {
    if preservesOwnColors {
      self.renderingMode(.original)
    } else {
      self
    }
  }
}
