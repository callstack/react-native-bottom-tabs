import SwiftUI

/**
 Helper used to render UIView inside of SwiftUI.
 Wraps each view with an additional wrapper to avoid directly managing React Native views.
 This solves issues where the layout would have weird artifacts..
 */
struct RepresentableView: PlatformViewRepresentable {
  var view: PlatformView
  var onInsetsChange: ((CGFloat, CGFloat, CGFloat, CGFloat) -> Void)? = nil

#if os(macOS)

  func makeNSView(context: Context) -> PlatformView {
    let wrapper = NSView()
    wrapper.addSubview(view)
    return wrapper
  }

  func updateNSView(_ nsView: PlatformView, context: Context) {}

#else

  func makeUIView(context: Context) -> PlatformView {
    let wrapper = SceneInsetsView()
    wrapper.onInsetsChange = onInsetsChange
    wrapper.addSubview(view)
    return wrapper
  }

  func updateUIView(_ uiView: PlatformView, context: Context) {
    guard let wrapper = uiView as? SceneInsetsView else { return }
    wrapper.onInsetsChange = onInsetsChange
    wrapper.reportInsets()
  }

#endif
}

#if !os(macOS)
private class SceneInsetsView: UIView {
  var onInsetsChange: ((CGFloat, CGFloat, CGFloat, CGFloat) -> Void)?
  private var lastInsets: UIEdgeInsets?

  override func safeAreaInsetsDidChange() {
    super.safeAreaInsetsDidChange()
    reportInsets()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    reportInsets()
  }

  func reportInsets() {
    guard window != nil, !bounds.isEmpty, let onInsetsChange else { return }
    let insets = safeAreaInsets
    guard lastInsets != insets else { return }
    lastInsets = insets
    onInsetsChange(insets.top, insets.right, insets.bottom, insets.left)
  }
}
#endif
