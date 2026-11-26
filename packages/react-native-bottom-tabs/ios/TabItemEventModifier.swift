import SwiftUI
import SwiftUIIntrospect
#if !os(macOS)
import UIKit
#endif

#if !os(macOS) && !os(visionOS)

struct TabItemEventResult {
  let preventsDefault: Bool
  let isLoaded: Bool
}

private final class ImmediateTabTransition: NSObject, UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    0
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard let destination = transitionContext.viewController(forKey: .to),
      let destinationView = transitionContext.view(forKey: .to)
    else {
      transitionContext.completeTransition(false)
      return
    }

    destinationView.frame = transitionContext.finalFrame(for: destination)
    transitionContext.containerView.addSubview(destinationView)
    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
  }
}

private final class TabBarDelegate: NSObject, UITabBarControllerDelegate {
  var onClick: ((_ index: Int?, _ identifier: String?) -> TabItemEventResult)?
  var disablePageAnimations = false

  func tabBarController(
    _ tabBarController: UITabBarController,
    animationControllerForTransitionFrom fromVC: UIViewController,
    to toVC: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    disablePageAnimations ? ImmediateTabTransition() : nil
  }

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if LongPressGestureHandler.isLongPressing(tabBarController.tabBar) {
      return false
    }

    if #available(iOS 27.0, *) {
      // iOS 27 routes SwiftUI TabView selection through shouldSelectTab.
      return true
    }

#if os(iOS)
    // Handle "More" Tab
    if tabBarController.moreNavigationController == viewController {
      return true
    }
#endif

    let isReselectingSameTab = tabBarController.selectedViewController == viewController

    if isReselectingSameTab {
      if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
        _ = onClick?(index, nil)
      }

      return false
    }

    // Unfortunately, due to iOS 26 new tab switching animations, controlling state from JavaScript is causing significant delays when switching tabs.
    // See: https://github.com/callstackincubator/react-native-bottom-tabs/issues/383
    // Due to this, whether the tab prevents default has to be defined statically.
    if let index = tabBarController.viewControllers?.firstIndex(of: viewController) {
      let defaultPrevented = onClick?(index, nil).preventsDefault ?? false

      return !defaultPrevented
    }

    return false
  }

  @available(iOS 18.0, tvOS 18.0, visionOS 2.0, *)
  func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
    guard #available(iOS 27.0, *) else {
      return true
    }

    if LongPressGestureHandler.isLongPressing(tabBarController.tabBar) {
      return false
    }

    let isReselectingSameTab =
      tabBarController.selectedTab === tab ||
      tabBarController.selectedTab?.identifier == tab.identifier

    let result = onClick?(
      tabIndex(for: tab, in: tabBarController),
      tab.identifier
    )

    if isReselectingSameTab || result?.preventsDefault == true {
      return false
    }

    // iOS 27 immediately displays the selected tab before React can mount a
    // lazy scene. Keep the current scene visible until the first render
    // updates the controlled selection, then use native selection as usual.
    return result?.isLoaded ?? true
  }

  @available(iOS 18.0, tvOS 18.0, visionOS 2.0, *)
  private func tabIndex(for tab: UITab, in tabBarController: UITabBarController) -> Int? {
    tabBarController.tabs.firstIndex {
      $0 === tab || $0.identifier == tab.identifier
    }
  }
}

struct TabItemEventModifier: ViewModifier {
  let disablePageAnimations: Bool
  let onTabEvent: (_ index: Int?, _ identifier: String?, _ isLongPress: Bool) -> TabItemEventResult
  private let delegate = TabBarDelegate()

  func body(content: Content) -> some View {
    content
      .introspectTabView { tabController in
        handle(tabController: tabController)
      }
  }

  func handle(tabController: UITabBarController) {
    delegate.disablePageAnimations = disablePageAnimations
    delegate.onClick = { index, identifier in
      onTabEvent(index, identifier, false)
    }
    tabController.delegate = delegate

    // Don't register gesutre recognizer more than one time
    if objc_getAssociatedObject(tabController.tabBar, &AssociatedKeys.gestureHandler) != nil {
      return
    }

    // Remove existing long press gestures
    if let existingGestures = tabController.tabBar.gestureRecognizers {
      for gesture in existingGestures where gesture is UILongPressGestureRecognizer {
        tabController.tabBar.removeGestureRecognizer(gesture)
      }
    }

    // Create gesture handler
    let handler = LongPressGestureHandler(tabBar: tabController.tabBar) { index, isLongPress in _ = onTabEvent(index, nil, isLongPress) }
    let gesture = UILongPressGestureRecognizer(target: handler, action: #selector(LongPressGestureHandler.handleLongPress(_:)))
    gesture.minimumPressDuration = 0.5
    gesture.delegate = handler

    objc_setAssociatedObject(tabController.tabBar, &AssociatedKeys.gestureHandler, handler, .OBJC_ASSOCIATION_RETAIN)

    tabController.tabBar.addGestureRecognizer(gesture)
  }
}

private struct AssociatedKeys {
  static var gestureHandler: UInt8 = 0
}

private class LongPressGestureHandler: NSObject {
  private weak var tabBar: UITabBar?
  private let handler: (Int, Bool) -> Void
  private var isLongPressing = false

  init(tabBar: UITabBar, handler: @escaping (Int, Bool) -> Void) {
    self.tabBar = tabBar
    self.handler = handler
    super.init()
  }

  /// Since iOS 26 the tab bar selects a tab when a long press on it ends.
  static func isLongPressing(_ tabBar: UITabBar) -> Bool {
    let handler = objc_getAssociatedObject(tabBar, &AssociatedKeys.gestureHandler) as? LongPressGestureHandler
    return handler?.isLongPressing ?? false
  }

  @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
    switch recognizer.state {
    case .began:
      isLongPressing = true
    case .ended, .cancelled, .failed:
      // The tab bar asks its delegate about the selection in the same touch-up, in either order.
      DispatchQueue.main.async { [weak self] in
        self?.isLongPressing = false
      }
    default:
      break
    }

    guard recognizer.state == .began,
          let tabBar else { return }

    let location = recognizer.location(in: tabBar)

    // Get buttons and sort them by frames, the first tab being the rightmost one in a right-to-left layout
    let isRightToLeft = tabBar.effectiveUserInterfaceLayoutDirection == .rightToLeft
    let buttonFrames = tabBar.tabButtons()
      .map { $0.convert($0.bounds, to: tabBar) }
      .sorted { isRightToLeft ? $0.minX > $1.minX : $0.minX < $1.minX }

    if let index = buttonFrames.firstIndex(where: { $0.contains(location) }) {
      handler(index, true)
    }
  }

  deinit {
    if let tabBar {
      objc_setAssociatedObject(tabBar, &AssociatedKeys.gestureHandler, nil, .OBJC_ASSOCIATION_RETAIN)
    }
  }
}

extension LongPressGestureHandler: UIGestureRecognizerDelegate {
  // The tab bar's own selection gesture starts on touch down since iOS 26 and would fail the long press.
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    true
  }
}

extension UIView {
  /// The buttons of a tab bar: `UITabBarButton` subviews before iOS 26, `_UITabButton` nested in the
  /// bar's platter since.
  func tabButtons() -> [UIView] {
    subviews.flatMap { subview -> [UIView] in
      let name = String(describing: type(of: subview))
      if name.contains("UITabBarButton") || name == "_UITabButton" {
        return [subview]
      }
      // Holds a second copy of every button, drawn over the selected one.
      if name == "SelectedContentView" {
        return []
      }
      return subview.tabButtons()
    }
  }
}

extension View {
  /**
   Event for tab items. The handler returns whether the tab prevents default (switching tabs) and whether React mounted its screen.
   */
  func onTabItemEvent(
    disablePageAnimations: Bool,
    _ handler: @escaping (Int?, String?, Bool) -> TabItemEventResult
  ) -> some View {
    modifier(TabItemEventModifier(disablePageAnimations: disablePageAnimations, onTabEvent: handler))
  }
}

#endif
