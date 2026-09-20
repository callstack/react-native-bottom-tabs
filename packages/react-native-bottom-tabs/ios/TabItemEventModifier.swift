import SwiftUI
import SwiftUIIntrospect
#if !os(macOS)
import UIKit
#endif

#if !os(macOS) && !os(visionOS)

private final class TabBarDelegate: NSObject, UITabBarControllerDelegate {
  var onClick: ((_ index: Int?, _ identifier: String?) -> Bool)?

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
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
      let defaultPrevented = onClick?(index, nil) ?? false

      return !defaultPrevented
    }

    return false
  }

  @available(iOS 18.0, tvOS 18.0, visionOS 2.0, *)
  func tabBarController(_ tabBarController: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
    guard #available(iOS 27.0, *) else {
      return true
    }

    let isReselectingSameTab =
      tabBarController.selectedTab === tab ||
      tabBarController.selectedTab?.identifier == tab.identifier

    // Unfortunately, due to iOS 26 new tab switching animations, controlling state from JavaScript is causing significant delays when switching tabs.
    // See: https://github.com/callstackincubator/react-native-bottom-tabs/issues/383
    // Due to this, whether the tab prevents default has to be defined statically.
    let defaultPrevented = onClick?(
      tabIndex(for: tab, in: tabBarController),
      tab.identifier
    ) ?? false

    return isReselectingSameTab ? false : !defaultPrevented
  }

  @available(iOS 18.0, tvOS 18.0, visionOS 2.0, *)
  private func tabIndex(for tab: UITab, in tabBarController: UITabBarController) -> Int? {
    tabBarController.tabs.firstIndex {
      $0 === tab || $0.identifier == tab.identifier
    }
  }
}

struct TabItemEventModifier: ViewModifier {
  let onTabEvent: (_ index: Int?, _ identifier: String?, _ isLongPress: Bool) -> Bool
  private let delegate = TabBarDelegate()

  func body(content: Content) -> some View {
    content
      .introspectTabView { tabController in
        handle(tabController: tabController)
      }
  }

  func handle(tabController: UITabBarController) {
    delegate.onClick = { index, identifier in
      onTabEvent(index, identifier, false)
    }
    tabController.delegate = delegate

    // Modern tab buttons (iOS 26+) can live outside UITabBar.
    // Observe the controller's hierarchy and leave UIKit's gestures intact.
    if let handler = objc_getAssociatedObject(tabController, &AssociatedKeys.gestureHandler) as? LongPressGestureHandler {
      handler.handler = { index in _ = onTabEvent(index, nil, true) }
      return
    }

    let handler = LongPressGestureHandler(tabController: tabController) { index in
      _ = onTabEvent(index, nil, true)
    }
    let gesture = UILongPressGestureRecognizer(target: handler, action: #selector(LongPressGestureHandler.handleLongPress(_:)))
    gesture.minimumPressDuration = 0.5
    gesture.cancelsTouchesInView = false
    gesture.delegate = handler

    objc_setAssociatedObject(tabController, &AssociatedKeys.gestureHandler, handler, .OBJC_ASSOCIATION_RETAIN)
    tabController.view.addGestureRecognizer(gesture)
  }
}

private struct AssociatedKeys {
  static var gestureHandler: UInt8 = 0
}

private final class LongPressGestureHandler: NSObject, UIGestureRecognizerDelegate {
  private weak var tabController: UITabBarController?
  private var pressedIndex: Int?
  var handler: (Int) -> Void

  init(tabController: UITabBarController, handler: @escaping (Int) -> Void) {
    self.tabController = tabController
    self.handler = handler
    super.init()
  }

  private func isTabButton(_ view: UIView) -> Bool {
    let name = String(describing: type(of: view))
    return name.contains("UITabBarButton") || name == "_UITabButton"
  }

  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    var view = touch.view
    while let candidate = view, candidate !== tabController?.view {
      if isTabButton(candidate) {
        // Capture the route before UIKit expands or duplicates the buttons
        // for its native long-press selection animation.
        pressedIndex = tabIndex(for: candidate)
        return pressedIndex != nil
      }
      view = candidate.superview
    }
    return false
  }

  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    true
  }

  @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
    guard recognizer.state == .began, let pressedIndex else { return }
    handler(pressedIndex)
  }

  private func tabIndex(for pressedButton: UIView) -> Int? {
    guard let tabController, let items = tabController.tabBar.items else { return nil }

    // UIKit may keep a second set of buttons for the selection animation.
    // Collapse identical frames before mapping the visible order to tab items.
    var buttons: [(view: UIView, frame: CGRect)] = []
    func collect(_ view: UIView) {
      guard !view.isHidden, view.alpha > 0.01 else { return }
      if isTabButton(view) {
        let frame = view.convert(view.bounds, to: tabController.view)
        if !frame.isEmpty, !buttons.contains(where: { $0.frame == frame }) {
          buttons.append((view, frame))
        }
        return
      }
      view.subviews.forEach(collect)
    }
    collect(tabController.view)

    let horizontalSpan = (buttons.map { $0.frame.midX }.max() ?? 0) - (buttons.map { $0.frame.midX }.min() ?? 0)
    let verticalSpan = (buttons.map { $0.frame.midY }.max() ?? 0) - (buttons.map { $0.frame.midY }.min() ?? 0)
    let isVertical = verticalSpan > horizontalSpan
    let isRTL = pressedButton.effectiveUserInterfaceLayoutDirection == .rightToLeft
    buttons.sort {
      if isVertical { return $0.frame.midY < $1.frame.midY }
      return isRTL ? $0.frame.midX > $1.frame.midX : $0.frame.midX < $1.frame.midX
    }

    let frame = pressedButton.convert(pressedButton.bounds, to: tabController.view)
    guard let index = buttons.firstIndex(where: { $0.frame == frame }),
          index < items.count else { return nil }
    #if os(iOS)
      // More opens an overflow menu; it is not the next route.
      guard items[index] !== tabController.moreNavigationController.tabBarItem else { return nil }
    #endif
    return index
  }
}

extension View {
  /**
   Event for tab items. Returns true if should prevent default (switching tabs).
   */
  func onTabItemEvent(_ handler: @escaping (Int?, String?, Bool) -> Bool) -> some View {
    modifier(TabItemEventModifier(onTabEvent: handler))
  }
}

#endif
