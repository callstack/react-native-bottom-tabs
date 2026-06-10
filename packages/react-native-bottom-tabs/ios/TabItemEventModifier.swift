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

  init(tabBar: UITabBar, handler: @escaping (Int, Bool) -> Void) {
    self.tabBar = tabBar
    self.handler = handler
    super.init()
  }

  @objc func handleLongPress(_ recognizer: UILongPressGestureRecognizer) {
    guard recognizer.state == .began,
          let tabBar else { return }

    let location = recognizer.location(in: tabBar)

    // Get buttons and sort them by frames
    let tabBarButtons = tabBar.subviews.filter { String(describing: type(of: $0)).contains("UITabBarButton") }.sorted { $0.frame.minX < $1.frame.minX }

    for (index, button) in tabBarButtons.enumerated() {
      if button.frame.contains(location) {
        handler(index, true)
        break
      }
    }
  }

  deinit {
    if let tabBar {
      objc_setAssociatedObject(tabBar, &AssociatedKeys.gestureHandler, nil, .OBJC_ASSOCIATION_RETAIN)
    }
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
