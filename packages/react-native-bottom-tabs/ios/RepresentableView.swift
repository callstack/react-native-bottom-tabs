import SwiftUI

#if os(tvOS)

private final class FocusRestoringView: UIView {
  private weak var lastFocusedView: UIView?
  private var lastFocusedTag: Int?

  override var preferredFocusEnvironments: [UIFocusEnvironment] {
    guard let lastFocusedView,
      let lastFocusedTag,
      lastFocusedView.tag == lastFocusedTag,
      lastFocusedView.window != nil,
      lastFocusedView.isDescendant(of: self),
      lastFocusedView.canBecomeFocused
    else {
      return super.preferredFocusEnvironments
    }

    return [lastFocusedView]
  }

  override func didUpdateFocus(
    in context: UIFocusUpdateContext,
    with coordinator: UIFocusAnimationCoordinator
  ) {
    super.didUpdateFocus(in: context, with: coordinator)

    if let nextFocusedView = context.nextFocusedView,
      nextFocusedView.isDescendant(of: self) {
      lastFocusedView = nextFocusedView
      lastFocusedTag = nextFocusedView.tag
    }
  }
}

#endif

/**
 Helper used to render UIView inside of SwiftUI.
 Wraps each view with an additional wrapper to avoid directly managing React Native views.
 This solves issues where the layout would have weird artifacts..
 */
struct RepresentableView: PlatformViewRepresentable {
  var view: PlatformView

#if os(macOS)

  func makeNSView(context: Context) -> PlatformView {
    let wrapper = NSView()
    wrapper.addSubview(view)
    return wrapper
  }

  func updateNSView(_ nsView: PlatformView, context: Context) {}

#else

  func makeUIView(context: Context) -> PlatformView {
#if os(tvOS)
    let wrapper = FocusRestoringView()
#else
    let wrapper = UIView()
#endif
    wrapper.addSubview(view)
    return wrapper
  }

  func updateUIView(_ uiView: PlatformView, context: Context) {}

#endif
}
