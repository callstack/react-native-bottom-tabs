import React
import SwiftUI

@available(iOS 18, macOS 15, visionOS 2, tvOS 18, *)
struct NewTabView: AnyTabView {
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
        if let index = props.children.firstIndex(of: child),
           let tabData = props.items[safe: index] {
          let isFocused = props.selectedPage == tabData.key

          if !tabData.hidden || isFocused {
            let icon = props.icons[index]

            let context = TabAppearContext(
              index: index,
              tabData: tabData,
              props: props,
              updateTabBarAppearance: updateTabBarAppearance,
              onSelect: onSelect
            )

            Tab(value: tabData.key, role: tabData.role?.convert()) {
              RepresentableView(view: child.view)
                .ignoresSafeArea(.container, edges: .all)
                .tabAppear(using: context)
                .hideTabBar(props.tabBarHidden)
            } label: {
              TabItem(
                title: tabData.title,
                icon: icon,
                sfSymbol: tabData.sfSymbol,
                labeled: props.labeled
              )
            }
            #if !os(tvOS)
            .badge(tabData.badge.flatMap { !$0.isEmpty ? Text($0) : nil })
            #endif
            .accessibilityIdentifier(tabData.testID ?? "")
          }
        }
      }
    }
    .environment(\.layoutDirection, effectiveLayoutDirection)
    .measureView { size in
      onLayout(size)
    }
    .modifier(ConditionalBottomAccessoryModifier(props: props))
  }
}

struct ConditionalBottomAccessoryModifier: ViewModifier {
  @ObservedObject var props: TabViewProps

  private var bottomAccessoryView: PlatformView? {
    props.children.first { child in
      let className = String(describing: type(of: child.view))
      return className == "RCTBottomAccessoryComponentView"
    }?.view
  }

  func body(content: Content) -> some View {
    #if os(macOS)
    // tabViewBottomAccessory is not available on macOS
    content
    #else
    if #available(iOS 26.0, tvOS 26.0, visionOS 3.0, *), bottomAccessoryView != nil {
      content
        .tabViewBottomAccessory {
          renderBottomAccessoryView()
        }
    } else {
      content
    }
    #endif
  }

  @ViewBuilder
  private func renderBottomAccessoryView() -> some View {
    #if !os(macOS)
    if let bottomAccessoryView {
      if #available(iOS 26.0, *) {
        BottomAccessoryRepresentableView(view: bottomAccessoryView)
      }
    }
    #endif
  }
}

#if !os(macOS)
@available(iOS 26.0, *)
struct BottomAccessoryRepresentableView: PlatformViewRepresentable {
  @Environment(\.tabViewBottomAccessoryPlacement) var tabViewBottomAccessoryPlacement
  var view: PlatformView

  func makeUIView(context: Context) -> PlatformView {
    let wrapper = UIView()
    wrapper.addSubview(view)

    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    emitPlacementChanged(for: view)
    return wrapper
  }

  func updateUIView(_ uiView: PlatformView, context: Context) {
    if let subview = uiView.subviews.first {
      subview.frame = uiView.bounds
    }
    emitPlacementChanged(for: view)
  }

  private func emitPlacementChanged(for uiView: PlatformView) {
    if let contentView = uiView.value(forKey: "bottomAccessoryProvider") as? BottomAccessoryProvider {
      contentView.emitPlacementChanged(tabViewBottomAccessoryPlacement)
    }
  }
}
#endif
