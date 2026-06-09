import SwiftUI

struct TabAppearContext {
  let index: Int
  let tabData: TabInfo
  let props: TabViewProps
  let updateTabBarAppearance: () -> Void
  let onSelect: (_ key: String) -> Void
}

struct TabAppearModifier: ViewModifier {
  let context: TabAppearContext

  func body(content: Content) -> some View {
    content.onAppear {
      #if !os(macOS)
        context.updateTabBarAppearance()
      #endif

      #if os(iOS)
        // Sync selection for tabs nested under the system "More" tab, which
        // only exists when there are more than 5 visible tabs. Without the
        // count guard the 5th tab (index 4) of a non-overflowing bar would
        // force-select itself whenever its scene re-appears (e.g. when the tab
        // bar is re-shown after `.hideTabBar`), hijacking the selection.
        if context.props.filteredItems.count > 5, context.index >= 4, context.props.selectedPage != context.tabData.key {
          context.onSelect(context.tabData.key)
          return
        }

        if #available(iOS 27.0, *), context.props.selectedPage != context.tabData.key {
          context.onSelect(context.tabData.key)
        }
      #endif
    }
  }
}

extension View {
  func tabAppear(using context: TabAppearContext) -> some View {
    self.modifier(TabAppearModifier(context: context))
  }
}
