import SwiftUI

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var labeled: Bool?
  var inactiveTintColor: PlatformColor?

  private var tint: Color? {
    inactiveTintColor.map(Color.init)
  }

  #if !os(macOS)
  private var tintedIcon: PlatformImage? {
    guard let icon else { return nil }
    guard let inactiveTintColor else { return icon }
    return icon.withTintColor(inactiveTintColor, renderingMode: .alwaysOriginal)
  }
  #endif

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
