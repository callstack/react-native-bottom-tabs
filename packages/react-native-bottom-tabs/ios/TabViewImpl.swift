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
        .onTabItemEvent { index, identifier, isLongPress in
          let item = identifier.flatMap { props.filteredItems.findByKey($0) }
            ?? index.flatMap { props.filteredItems[safe: $0] }
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
          updateTabBarItemImages(props: props, tabBar: tabController.tabBar)
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
  private func updateTabBarItemImages(props: TabViewProps, tabBar: UITabBar?) {
    guard let tabBar,
      let items = tabBar.items
    else { return }

    configureTabBarItemImages(items: items, props: props)

    DispatchQueue.main.async { [weak tabBar] in
      guard let tabBar, let items = tabBar.items else { return }
      configureTabBarItemImages(items: items, props: props)
    }
  }

  private func updateTabBarAppearance(props: TabViewProps, tabBar: UITabBar?) {
    guard let tabBar else { return }

    tabBar.isHidden = props.tabBarHidden

    if props.scrollEdgeAppearance == "transparent" {
      configureTransparentAppearance(tabBar: tabBar, props: props)
      return
    }

    configureStandardAppearance(tabBar: tabBar, props: props)
  }
#endif

#if !os(macOS)
  private func configureTransparentAppearance(tabBar: UITabBar, props: TabViewProps) {
    tabBar.barTintColor = props.barTintColor
    tabBar.tintColor = props.selectedActiveTintColor
    #if !os(visionOS)
      tabBar.isTranslucent = props.translucent
    #endif
    tabBar.unselectedItemTintColor = props.effectiveInactiveTintColor

    guard let items = tabBar.items else { return }

    let fontAttributes = TabBarFontSize.createNormalStateAttributes(
      fontSize: props.fontSize,
      fontFamily: props.fontFamily,
      fontWeight: props.fontWeight,
      inactiveColor: nil
    )

    items.forEach { item in
      item.setTitleTextAttributes(fontAttributes, for: .normal)
      item.setTitleTextAttributes(selectedAttributes(props: props), for: .selected)
    }
  }

  private func configureStandardAppearance(tabBar: UITabBar, props: TabViewProps) {
    let appearance = UITabBarAppearance()
    tabBar.tintColor = props.selectedActiveTintColor
    tabBar.unselectedItemTintColor = props.effectiveInactiveTintColor

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
      inactiveColor: props.effectiveInactiveTintColor
    )

    if let inactiveTintColor = props.effectiveInactiveTintColor {
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
  }

  /// Configures the parts of the tab bar items that SwiftUI can't express.
  ///
  /// The unselected image is owned by SwiftUI through the tab label (see `TabBarItemImages.labelImage`),
  /// so it's never assigned here. Assigning item images while the tab bar animates (e.g. minimizing or
  /// switching tabs) breaks its selection styling on iOS 27, so `selectedImage` is only assigned when it
  /// changes, and SwiftUI updates its images only when a label changes.
  private func configureTabBarItemImages(items: [UITabBarItem], props: TabViewProps) {
    for (tabBarIndex, item) in items.enumerated() {
      guard let tabData = props.filteredItems[safe: tabBarIndex] else { continue }

      let tabActiveColor = tabData.activeTintColor ?? props.activeTintColor
      let images = props.itemImages.images(for: tabData, props: props)

      item.accessibilityLabel = tabData.title

      if let images {
        assignSelectedImage(images.selectedImage, to: item)
      }

      if images?.rendersLabelIntoImage == true {
        item.title = ""
        item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 100)
        continue
      }

      item.title = props.labeled ? tabData.title : nil
      item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 0)

      item.setTitleTextAttributes(
        TabBarFontSize.createFontAttributes(
          size: props.fontSize.map(CGFloat.init) ?? TabBarFontSize.defaultSize,
          family: props.fontFamily,
          weight: props.fontWeight,
          color: tabActiveColor
        ),
        for: .selected
      )
    }
  }

  private func assignSelectedImage(_ image: UIImage, to item: UITabBarItem) {
    // `UITabBarItem.selectedImage` returns a copy, so compare against the last assigned instance instead.
    let assignedImage = objc_getAssociatedObject(item, &AssociatedKeys.selectedImage) as? UIImage
    guard assignedImage !== image else { return }

    item.selectedImage = image
    objc_setAssociatedObject(item, &AssociatedKeys.selectedImage, image, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
  }

  private enum AssociatedKeys {
    static var selectedImage: UInt8 = 0
  }

  struct TabBarItemImages {
    /// Replaces the icon of the tab's SwiftUI label, or `nil` to keep the tab's own icon.
    let labelImage: UIImage?
    let selectedImage: UIImage
    let rendersLabelIntoImage: Bool
  }

  final class TabBarItemImageCache {
    private var entries: [String: (inputs: Inputs, images: TabBarItemImages?)] = [:]

    func images(for tabData: TabInfo, props: TabViewProps) -> TabBarItemImages? {
      guard let itemIndex = props.items.firstIndex(where: { $0.key == tabData.key }) else { return nil }

      let assetIcon = props.icons[itemIndex]
      let focusedAssetIcon = props.focusedIcons[itemIndex]
      let useBakedTintColors = shouldUseExperimentalBakedTintColors(props: props)
      let hasEffectiveRole: Bool
      if #available(iOS 18, macOS 15, visionOS 2, tvOS 18, *) {
        hasEffectiveRole = tabData.role?.convert() != nil
      } else {
        hasEffectiveRole = false
      }
      let inputs = Inputs(
        icon: assetIcon.map(IconSource.image) ?? .sfSymbol(tabData.sfSymbol),
        focusedIcon: focusedAssetIcon.map(IconSource.image) ?? tabData.focusedSfSymbol.map(IconSource.sfSymbol),
        title: tabData.title,
        inactiveTintColor: props.inactiveTintColor,
        activeTintColor: tabData.activeTintColor ?? props.activeTintColor,
        preservesOriginalIconColors: tabData.iconRenderingMode == "original",
        useBakedTintColors: useBakedTintColors,
        rendersLabelIntoImage: useBakedTintColors && props.hasCustomTintColors && props.labeled && !hasEffectiveRole,
        fontSize: props.fontSize,
        fontFamily: props.fontFamily,
        fontWeight: props.fontWeight
      )

      if let entry = entries[tabData.key], entry.inputs == inputs {
        return entry.images
      }

      let images = render(
        icon: assetIcon ?? makeSFSymbolImage(named: tabData.sfSymbol),
        focusedIcon: focusedAssetIcon ?? makeSFSymbolImage(named: tabData.focusedSfSymbol),
        inputs: inputs,
        props: props
      )
      entries[tabData.key] = (inputs, images)
      return images
    }

    private func render(
      icon: UIImage?,
      focusedIcon: UIImage?,
      inputs: Inputs,
      props: TabViewProps
    ) -> TabBarItemImages? {
      guard let icon else { return nil }
      let selectedIcon = focusedIcon ?? icon

      if inputs.rendersLabelIntoImage {
        return TabBarItemImages(
          labelImage: makeTabBarItemImage(
            icon: icon,
            title: inputs.title,
            color: inputs.inactiveTintColor,
            preservesOriginalIconColors: inputs.preservesOriginalIconColors,
            props: props
          ),
          selectedImage: makeTabBarItemImage(
            icon: selectedIcon,
            title: inputs.title,
            color: inputs.activeTintColor,
            preservesOriginalIconColors: inputs.preservesOriginalIconColors,
            props: props
          ),
          rendersLabelIntoImage: true
        )
      }

      return TabBarItemImages(
        // Without baked tint colors, the tab's own icon is already what the label shows.
        labelImage: inputs.useBakedTintColors
          ? renderTabBarIcon(
            icon,
            color: inputs.inactiveTintColor,
            preservesOriginalIconColors: inputs.preservesOriginalIconColors,
            forceTintColor: true
          )
          : nil,
        selectedImage: renderTabBarIcon(
          selectedIcon,
          color: inputs.activeTintColor,
          preservesOriginalIconColors: inputs.preservesOriginalIconColors,
          forceTintColor: inputs.useBakedTintColors
        ),
        rendersLabelIntoImage: false
      )
    }

    private enum IconSource: Equatable {
      case image(UIImage)
      case sfSymbol(String)

      static func == (lhs: IconSource, rhs: IconSource) -> Bool {
        switch (lhs, rhs) {
        case let (.image(lhs), .image(rhs)):
          return lhs === rhs
        case let (.sfSymbol(lhs), .sfSymbol(rhs)):
          return lhs == rhs
        default:
          return false
        }
      }
    }

    private struct Inputs: Equatable {
      let icon: IconSource
      let focusedIcon: IconSource?
      let title: String
      let inactiveTintColor: UIColor?
      let activeTintColor: UIColor?
      let preservesOriginalIconColors: Bool
      let useBakedTintColors: Bool
      let rendersLabelIntoImage: Bool
      let fontSize: Int?
      let fontFamily: String?
      let fontWeight: String?
    }
  }

  private func renderTabBarIcon(
    _ icon: UIImage,
    color: UIColor?,
    preservesOriginalIconColors: Bool,
    forceTintColor: Bool
  ) -> UIImage {
    if preservesOriginalIconColors {
      return icon.withRenderingMode(.alwaysOriginal)
    }

    guard forceTintColor, let color else {
      return icon
    }

    return icon.withTintColor(color, renderingMode: .alwaysOriginal)
  }

  private func makeSFSymbolImage(named sfSymbol: String?) -> UIImage? {
    guard let sfSymbol, !sfSymbol.isEmpty else { return nil }

    return UIImage(systemName: sfSymbol)
  }

  private func selectedAttributes(props: TabViewProps) -> [NSAttributedString.Key: Any] {
    TabBarFontSize.createFontAttributes(
      size: props.fontSize.map(CGFloat.init) ?? TabBarFontSize.defaultSize,
      family: props.fontFamily,
      weight: props.fontWeight,
      color: props.selectedActiveTintColor
    )
  }

  private func shouldUseExperimentalBakedTintColors(props: TabViewProps) -> Bool {
    guard props.experimentalBakedTintColors else {
      return false
    }

    #if os(iOS)
      if #available(iOS 26.0, *) {
        return true
      }
    #endif

    return false
  }

  private func makeTabBarItemImage(
    icon: UIImage,
    title: String,
    color: UIColor?,
    preservesOriginalIconColors: Bool = false,
    props: TabViewProps
  ) -> UIImage {
    let color = color ?? .label
    let iconSize = CGSize(width: 27, height: 27)
    let font =
      TabBarFontSize.createFontAttributes(
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
      let tintedIcon: UIImage
      if preservesOriginalIconColors {
        tintedIcon = icon.withRenderingMode(.alwaysOriginal)
      } else {
        tintedIcon = icon.withTintColor(color, renderingMode: .alwaysOriginal)
      }
      let iconFrame = aspectFitRect(
        size: tintedIcon.size,
        in: CGRect(
          x: (imageSize.width - iconSize.width) / 2,
          y: 0,
          width: iconSize.width,
          height: iconSize.height
        )
      )

      tintedIcon.draw(in: iconFrame)

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

  private func aspectFitRect(size: CGSize, in rect: CGRect) -> CGRect {
    guard size.width > 0, size.height > 0 else {
      return rect
    }

    let scale = min(rect.width / size.width, rect.height / size.height)
    let fittedSize = CGSize(width: size.width * scale, height: size.height * scale)

    return CGRect(
      x: rect.minX + (rect.width - fittedSize.width) / 2,
      y: rect.minY + (rect.height - fittedSize.height) / 2,
      width: fittedSize.width,
      height: fittedSize.height
    )
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
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.activeTintColor) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.selectedActiveTintColor) { newValue in
          tabBar?.tintColor = newValue
        }
        .onChange(of: props.iconsRevision) { _ in
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.labeled) { _ in
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontSize) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontFamily) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.fontWeight) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
          updateTabBarItemImages(props: props, tabBar: tabBar)
        }
        .onChange(of: props.experimentalBakedTintColors) { _ in
          updateTabBarAppearance(props: props, tabBar: tabBar)
          updateTabBarItemImages(props: props, tabBar: tabBar)
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
