import SwiftUI

struct TabItem: View {
  var title: String?
  var icon: PlatformImage?
  var sfSymbol: String?
  var labeled: Bool?
  var iconRenderingMode: String?

  var body: some View {
    if let icon {
#if os(macOS)
      Image(nsImage: icon)
#else
      Image(uiImage: icon.withRenderingMode(uiImageRenderingMode))
        .renderingMode(swiftUIImageRenderingMode)
#endif
    } else if let sfSymbol, !sfSymbol.isEmpty {
      Image(systemName: sfSymbol)
        .noneSymbolVariant()
    }
    if labeled != false {
      Text(title ?? "")
    }
  }

#if !os(macOS)
  private var preservesOriginalIconColors: Bool {
    iconRenderingMode == "alwaysOriginal"
  }

  private var uiImageRenderingMode: UIImage.RenderingMode {
    preservesOriginalIconColors ? .alwaysOriginal : .automatic
  }

  private var swiftUIImageRenderingMode: Image.TemplateRenderingMode? {
    preservesOriginalIconColors ? .original : nil
  }
#endif
}
