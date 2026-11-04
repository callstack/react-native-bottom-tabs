import SwiftUI

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
    #if os(iOS)
      let wrapper = ContentScrollViewWrapper()
    #else
      let wrapper = UIView()
    #endif
    wrapper.addSubview(view)
    return wrapper
  }

  func updateUIView(_ uiView: PlatformView, context: Context) {}

#endif
}

#if os(iOS)
  final class ContentScrollViewWrapper: UIView, UIGestureRecognizerDelegate {
    override init(frame: CGRect) {
      super.init(frame: frame)
      let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
      pan.cancelsTouchesInView = false
      pan.delaysTouchesBegan = false
      pan.delaysTouchesEnded = false
      pan.delegate = self
      addGestureRecognizer(pan)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
      super.layoutSubviews()
      scheduleUpdate()
    }

    override func didMoveToWindow() {
      super.didMoveToWindow()
      scheduleUpdate()
    }

    func gestureRecognizer(
      _ gestureRecognizer: UIGestureRecognizer,
      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
      true
    }

    @objc private func handlePan(_ pan: UIPanGestureRecognizer) {
      guard pan.state == .began else { return }
      var view = hitTest(pan.location(in: self), with: nil)
      var outermost: UIScrollView?
      while let current = view, current !== self {
        if let scrollView = current as? UIScrollView, scrollView.isScrollEnabled,
          scrollView.contentSize.height > scrollView.bounds.height || scrollView.alwaysBounceVertical {
          outermost = scrollView
        }
        view = current.superview
      }
      if let outermost {
        setContentScrollView(outermost)
      }
    }

    private func scheduleUpdate() {
      setContentScrollView(findMainScrollView())
      DispatchQueue.main.async { [weak self] in
        self?.setContentScrollView(self?.findMainScrollView())
      }
    }

    private func setContentScrollView(_ scrollView: UIScrollView?) {
      guard #available(iOS 26.0, *), let scrollView, window != nil,
        let tabController = viewController(above: self) else {
        return
      }
      var controllers = [tabController]
      var current: UIView? = scrollView
      while let view = current, let controller = viewController(above: view), controller !== tabController {
        controllers.append(controller)
        current = controller.view.superview
      }
      for controller in controllers where controller.contentScrollView(for: .bottom) !== scrollView {
        controller.setContentScrollView(scrollView, for: .bottom)
      }
    }

    private func viewController(above view: UIView) -> UIViewController? {
      var responder: UIResponder? = view.next
      while let current = responder {
        if let controller = current as? UIViewController {
          return controller
        }
        responder = current.next
      }
      return nil
    }

    private func isMainScrollView(_ scrollView: UIScrollView) -> Bool {
      scrollView.isScrollEnabled && scrollView.bounds.height >= bounds.height / 2
    }

    private func findMainScrollView() -> UIScrollView? {
      guard bounds.height > 0 else { return nil }
      var queue = subviews
      var index = 0
      while index < queue.count {
        let view = queue[index]
        index += 1
        if view.isHidden { continue }
        if let scrollView = view as? UIScrollView, isMainScrollView(scrollView) {
          return scrollView
        }
        queue.append(contentsOf: view.subviews)
      }
      return nil
    }
  }
#endif
