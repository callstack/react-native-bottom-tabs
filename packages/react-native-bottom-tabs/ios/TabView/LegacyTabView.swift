import SwiftUI

struct LegacyTabView: AnyTabView {
  @ObservedObject var props: TabViewProps

  var onLayout: (CGSize) -> Void
  var onSelect: (String) -> Void
  var updateTabBarAppearance: () -> Void

  private var effectiveLayoutDirection: LayoutDirection {
    let dir = props.layoutDirection ?? "locale"
    if let mapped = ["rtl": LayoutDirection.rightToLeft,
                     "ltr": LayoutDirection.leftToRight][dir] {
      return mapped
    }
    let system = UIView.userInterfaceLayoutDirection(for: .unspecified)
    return system == .rightToLeft ? .rightToLeft : .leftToRight
  }

  @ViewBuilder
  var body: some View {
    TabView(selection: $props.selectedPage) {
      ForEach(props.children) { child in
        if let index = props.children.firstIndex(of: child) {
          renderTabItem(at: index)
        }
      }
      .measureView { size in
        onLayout(size)
      }
    }
    .environment(\.layoutDirection, effectiveLayoutDirection)
    .hideTabBar(props.tabBarHidden)
  }

  @ViewBuilder
  private func renderTabItem(at index: Int) -> some View {
    if let tabData = props.items[safe: index] {
      let isFocused = props.selectedPage == tabData.key

      if !tabData.hidden || isFocused {
        let icon = props.icons[index]
        let child = props.children[safe: index]?.view ?? PlatformView()
        let context = TabAppearContext(
          index: index,
          tabData: tabData,
          props: props,
          updateTabBarAppearance: updateTabBarAppearance,
          onSelect: onSelect
        )

        RepresentableView(view: child)
          .ignoresSafeArea(.container, edges: .all)
          .tabItem {
            TabItem(
              title: tabData.title,
              icon: icon,
              sfSymbol: tabData.sfSymbol,
              labeled: props.labeled
            )
            .accessibilityIdentifier(tabData.testID ?? "")
          }
          .tag(tabData.key)
          .tabBadge(tabData.badge)
          .tabAppear(using: context)
      }
    }
  }
}
