import Foundation
import React
import SwiftUI
@_spi(Advanced) import SwiftUIIntrospect

/// SwiftUI implementation of TabView used to render React Native views.
struct TabViewImpl: View {
  @ObservedObject var props: TabViewProps
  #if os(macOS)
    @Weak var tabBar: NSTabView?
  #else
    @Weak var tabBar: UITabBar?
  #endif

  @ViewBuilder
  var tabContent: some View {
    if #available(iOS 18, macOS 15, visionOS 2, tvOS 18, *) {
      NewTabView(
        props: props,
        onLayout: onLayout,
        onSelect: onSelect
      ) {
        #if !os(macOS)
        updateTabBarAppearance(props: props, tabBar: tabBar)
        #endif
      }
    } else {
      LegacyTabView(
        props: props,
        onLayout: onLayout,
        onSelect: onSelect
      ) {
        #if !os(macOS)
        updateTabBarAppearance(props: props, tabBar: tabBar)
        #endif
      }
    }
  }

  var onSelect: (_ key: String) -> Void
  var onLongPress: (_ key: String) -> Void
  var onLayout: (_ size: CGSize) -> Void
  var onTabBarMeasured: (_ height: Int) -> Void

  var body: some View {
    tabContent
      .tabBarMinimizeBehavior(props.minimizeBehavior)
      #if !os(tvOS) && !os(macOS) && !os(visionOS)
        .onTabItemEvent { index, isLongPress in
          let item = props.filteredItems[safe: index]
          guard let key = item?.key else { return false }

          if isLongPress {
            onLongPress(key)
            emitHapticFeedback(longPress: true)
          } else {
            onSelect(key)
            emitHapticFeedback()
          }
          return item?.preventsDefault ?? false
        }
      #endif
      .introspectTabView { tabController in
#if !os(macOS)
        tabController.view.backgroundColor = .clear
        tabController.viewControllers?.forEach { $0.view.backgroundColor = .clear }
#endif
        #if os(macOS)
          tabBar = tabController
        #else
          tabBar = tabController.tabBar
          updateTabBarAppearance(props: props, tabBar: tabController.tabBar)
          if !props.tabBarHidden {
            onTabBarMeasured(
              Int(tabController.tabBar.frame.size.height)
            )
          }
        #endif
      }
      #if !os(macOS)
        .configureAppearance(props: props, tabBar: tabBar)
      #endif
      .tintColor(props.selectedActiveTintColor)
      .getSidebarAdaptable(enabled: props.sidebarAdaptable ?? false)
      .onChange(of: props.selectedPage ?? "") { newValue in
        #if !os(macOS)
          updateTabBarAppearance(props: props, tabBar: tabBar)
        #endif
        #if !os(macOS)
          if props.disablePageAnimations {
            UIView.setAnimationsEnabled(false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
              UIView.setAnimationsEnabled(true)
            }
          }
        #endif
        #if os(tvOS) || os(macOS) || os(visionOS)
          onSelect(newValue)
        #endif
      }
  }

  func emitHapticFeedback(longPress: Bool = false) {
    #if os(iOS)
      if !props.hapticFeedbackEnabled {
        return
      }

      if longPress {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
      } else {
        UISelectionFeedbackGenerator().selectionChanged()
      }
    #endif
  }
}

#if !os(macOS)
  private func updateTabBarAppearance(props: TabViewProps, tabBar: UITabBar?) {
    guard let tabBar else { return }

    tabBar.isHidden = props.tabBarHidden

    if props.scrollEdgeAppearance == "transparent" {
      configureTransparentAppearance(tabBar: tabBar, props: props)
      return
    } else {
      configureStandardAppearance(tabBar: tabBar, props: props)
    }
  }
#endif

#if !os(macOS)
  private func configureTransparentAppearance(tabBar: UITabBar, props: TabViewProps) {
    tabBar.barTintColor = props.barTintColor
    tabBar.tintColor = props.selectedActiveTintColor
    #if !os(visionOS)
      tabBar.isTranslucent = props.translucent
    #endif
    tabBar.unselectedItemTintColor = props.inactiveTintColor

    guard let items = tabBar.items else { return }
    configureTabBarItemImages(items: items, props: props)

    let attributes = TabBarFontSize.createNormalStateAttributes(
      fontSize: props.fontSize,
      fontFamily: props.fontFamily,
      fontWeight: props.fontWeight,
      inactiveColor: props.inactiveTintColor
    )

    items.forEach { item in
      item.setTitleTextAttributes(attributes, for: .normal)
      item.setTitleTextAttributes(selectedAttributes(props: props), for: .selected)
    }
    configureTabBarItemImagesAfterLayout(tabBar: tabBar, props: props)
  }

  private func configureStandardAppearance(tabBar: UITabBar, props: TabViewProps) {
    let appearance = UITabBarAppearance()
    tabBar.tintColor = props.selectedActiveTintColor
    tabBar.unselectedItemTintColor = props.inactiveTintColor

    // Configure background
    switch props.scrollEdgeAppearance {
    case "opaque":
      appearance.configureWithOpaqueBackground()
    default:
      appearance.configureWithDefaultBackground()
    }

    if props.translucent == false {
      appearance.configureWithOpaqueBackground()
    }

    if props.barTintColor != nil {
      appearance.backgroundColor = props.barTintColor
    }

    // Configure item appearance
    let itemAppearance = UITabBarItemAppearance()

    let attributes = TabBarFontSize.createNormalStateAttributes(
      fontSize: props.fontSize,
      fontFamily: props.fontFamily,
      fontWeight: props.fontWeight,
      inactiveColor: props.inactiveTintColor
    )

    if let inactiveTintColor = props.inactiveTintColor {
      itemAppearance.normal.iconColor = inactiveTintColor
    }
    if let activeTintColor = props.selectedActiveTintColor {
      itemAppearance.selected.iconColor = activeTintColor
    }

    itemAppearance.normal.titleTextAttributes = attributes
    itemAppearance.selected.titleTextAttributes = selectedAttributes(props: props)

    // Apply item appearance to all layouts
    appearance.stackedLayoutAppearance = itemAppearance
    appearance.inlineLayoutAppearance = itemAppearance
    appearance.compactInlineLayoutAppearance = itemAppearance

    // Apply final appearance
    tabBar.standardAppearance = appearance
    if #available(iOS 15.0, *) {
      tabBar.scrollEdgeAppearance = appearance.copy()
    }
    if let items = tabBar.items {
      configureTabBarItemImages(items: items, props: props)
      configureTabBarItemTitles(items: items, props: props)
      configureTabBarItemImagesAfterLayout(tabBar: tabBar, props: props)
    }
  }

  private func configureTabBarItemTitles(items: [UITabBarItem], props: TabViewProps) {
    let normalAttributes = TabBarFontSize.createNormalStateAttributes(
      fontSize: props.fontSize,
      fontFamily: props.fontFamily,
      fontWeight: props.fontWeight,
      inactiveColor: props.inactiveTintColor
    )
    let selectedAttributes = selectedAttributes(props: props)

    items.forEach { item in
      item.setTitleTextAttributes(normalAttributes, for: .normal)
      item.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
  }

  private func configureTabBarItemImages(items: [UITabBarItem], props: TabViewProps) {
    for (tabBarIndex, item) in items.enumerated() {
      guard let tabData = props.filteredItems[safe: tabBarIndex],
            let itemIndex = props.items.firstIndex(where: { $0.key == tabData.key }),
            let icon = props.icons[itemIndex] else { continue }

      if shouldRenderTabBarLabelsIntoImages(), props.labeled {
        item.title = ""
        item.accessibilityLabel = tabData.title
        item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 100)
        item.image = makeTabBarItemImage(
          icon: icon,
          title: tabData.title,
          color: props.inactiveTintColor,
          props: props
        )
        item.selectedImage = makeTabBarItemImage(
          icon: icon,
          title: tabData.title,
          color: props.selectedActiveTintColor,
          props: props
        )
        continue
      }

      item.image = props.inactiveTintColor.map {
        icon.withTintColor($0, renderingMode: .alwaysOriginal)
      } ?? icon
      item.selectedImage = props.selectedActiveTintColor.map {
        icon.withTintColor($0, renderingMode: .alwaysOriginal)
      } ?? icon
    }
  }

  private func configureTabBarItemImagesAfterLayout(tabBar: UITabBar, props: TabViewProps) {
    guard shouldRenderTabBarLabelsIntoImages() else { return }

    DispatchQueue.main.async { [weak tabBar] in
      guard let tabBar, let items = tabBar.items else { return }
      configureTabBarItemImages(items: items, props: props)
    }
  }

  private func selectedAttributes(props: TabViewProps) -> [NSAttributedString.Key: Any] {
    TabBarFontSize.createFontAttributes(
      size: props.fontSize.map(CGFloat.init) ?? TabBarFontSize.defaultSize,
      family: props.fontFamily,
      weight: props.fontWeight,
      color: props.selectedActiveTintColor
    )
  }

  private func shouldRenderTabBarLabelsIntoImages() -> Bool {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    return version.majorVersion > 26 || (version.majorVersion == 26 && version.minorVersion >= 4)
  }

  private func makeTabBarItemImage(
    icon: UIImage,
    title: String,
    color: UIColor?,
    props: TabViewProps
  ) -> UIImage {
    let color = color ?? .label
    let iconSize = CGSize(width: 27, height: 27)
    let font = TabBarFontSize.createFontAttributes(
      size: props.fontSize.map(CGFloat.init) ?? TabBarFontSize.defaultSize,
      family: props.fontFamily,
      weight: props.fontWeight
    )[.font] as? UIFont ?? UIFont.boldSystemFont(ofSize: TabBarFontSize.defaultSize)
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.alignment = .center
    let attributes: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraphStyle,
    ]
    let titleSize = (title as NSString).size(withAttributes: attributes)
    let imageSize = CGSize(
      width: max(iconSize.width, ceil(titleSize.width)) + 8,
      height: iconSize.height + 3 + ceil(titleSize.height)
    )
    let format = UIGraphicsImageRendererFormat()
    format.scale = UIScreen.main.scale

    let image = UIGraphicsImageRenderer(size: imageSize, format: format).image { _ in
      let tintedIcon = icon.withTintColor(color, renderingMode: .alwaysOriginal)
      tintedIcon.draw(in: CGRect(
        x: (imageSize.width - iconSize.width) / 2,
        y: 0,
        width: iconSize.width,
        height: iconSize.height
      ))

      (title as NSString).draw(
        in: CGRect(
          x: 0,
          y: iconSize.height + 3,
          width: imageSize.width,
          height: ceil(titleSize.height)
        ),
        withAttributes: attributes
      )
    }

    return image.withRenderingMode(.alwaysOriginal)
  }
#endif

extension View {
  @ViewBuilder
  func getSidebarAdaptable(enabled: Bool) -> some View {
    if #available(iOS 18.0, macOS 15.0, tvOS 18.0, visionOS 2.0, *) {
      if enabled {
        #if compiler(>=6.0)
          self.tabViewStyle(.sidebarAdaptable)
        #else
          self
        #endif
      } else {
        self
      }
    } else {
      self
    }
  }

  @ViewBuilder
  func tabBadge(_ data: String?) -> some View {
    if #available(iOS 15.0, macOS 15.0, visionOS 2.0, tvOS 15.0, *) {
      if let data {
        #if !os(tvOS)
          self.badge(data)
        #else
          self
        #endif
      } else {
        self
      }
    } else {
      self
    }
  }

  #if !os(macOS)
    @ViewBuilder
    func configureAppearance(props: TabViewProps, tabBar: UITabBar?) -> some View {
      self
        .onChange(of: props.barTintColor) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.scrollEdgeAppearance) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.translucent) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.inactiveTintColor) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.selectedActiveTintColor) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.iconsRevision) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontSize) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontFamily) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontWeight) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
        }
        .onChange(of: props.tabBarHidden) { newValue in
          tabBar?.isHidden = newValue
        }
    }
  #endif

  @ViewBuilder
  func tintColor(_ color: PlatformColor?) -> some View {
    let color = color.map(Color.init)

    if #available(iOS 16.0, tvOS 16.0, macOS 13.0, *) {
      self.tint(color)
    } else {
      self.accentColor(color)
    }
  }

  @ViewBuilder
  func tabBarMinimizeBehavior(_ behavior: MinimizeBehavior?) -> some View {
    #if compiler(>=6.2)
    if #available(iOS 26.0, macOS 26.0, tvOS 26.0, *) {
        if let behavior {
          self.tabBarMinimizeBehavior(behavior.convert())
        } else {
          self
        }
      } else {
        self
      }
    #else
      self
    #endif
  }

  @ViewBuilder
  func hideTabBar(_ flag: Bool) -> some View {
    #if !os(macOS)
      if flag {
        if #available(iOS 16.0, tvOS 16.0, *) {
          self.toolbar(.hidden, for: .tabBar)
        } else {
          // We fallback to isHidden on UITabBar
          self
        }
      } else {
        self
      }
    #else
      self
    #endif
  }

  // Allows TabView to use unfilled SFSymbols.
  // By default they are always filled.
  @ViewBuilder
  func noneSymbolVariant() -> some View {
    if #available(iOS 15.0, tvOS 15.0, macOS 13.0, *) {
      self
        .environment(\.symbolVariants, .none)
    } else {
      self
    }
  }
}
