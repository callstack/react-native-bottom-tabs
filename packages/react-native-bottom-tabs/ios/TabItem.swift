import SwiftUI

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var labeled: Bool?
  var tintColor: PlatformColor?

  private var tint: Color? {
    tintColor.map(Color.init)
  }

  #if !os(macOS)
  private var tintedIcon: PlatformImage? {
    guard let icon else { return nil }
    guard let tintColor else { return icon }
    return icon.withTintColor(tintColor, renderingMode: .alwaysOriginal)
  }
  #endif

  @ViewBuilder
  var body: some View {
    if let icon {
#if os(macOS)
      Image(nsImage: icon)
#else
      Image(uiImage: tintedIcon ?? icon)
#endif
    } else if let sfSymbol, !sfSymbol.isEmpty {
      Image(systemName: sfSymbol)
        .noneSymbolVariant()
        .foregroundColor(tint)
    }
    if labeled != false {
      Text(title ?? "")
        .foregroundColor(tint)
    }
  }
}
