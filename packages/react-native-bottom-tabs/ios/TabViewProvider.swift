import Foundation
import React
import SwiftUI

@objcMembers
public final class TabInfo: NSObject {
  public let key: String
  public let title: String
  public let badge: String?
  public let sfSymbol: String
  public let focusedSfSymbol: String?
  public let activeTintColor: PlatformColor?
  public let iconRenderingMode: String?
  public let hidden: Bool
  public let testID: String?
  public let role: TabBarRole?
  public let preventsDefault: Bool

  public init(
    key: String,
    title: String,
    badge: String?,
    sfSymbol: String,
    focusedSfSymbol: String?,
    activeTintColor: PlatformColor?,
    iconRenderingMode: String?,
    hidden: Bool,
    testID: String?,
    role: String?,
    preventsDefault: Bool = false
  ) {
    self.key = key
    self.title = title
    self.badge = badge
    self.sfSymbol = sfSymbol
    self.focusedSfSymbol = focusedSfSymbol
    self.activeTintColor = activeTintColor
    self.iconRenderingMode = iconRenderingMode
    self.hidden = hidden
    self.testID = testID
    self.role = TabBarRole(rawValue: role ?? "")
    self.preventsDefault = preventsDefault
    super.init()
  }
}

@objc public protocol TabViewProviderDelegate {
  func onPageSelected(key: String, reactTag: NSNumber?)
  func onLongPress(key: String, reactTag: NSNumber?)
  func onTabBarMeasured(height: Int, reactTag: NSNumber?)
  func onLayout(size: CGSize, reactTag: NSNumber?)
}

@objc public class TabViewProvider: PlatformView {
  private var imageLoader: RCTImageLoaderProtocol?
  private weak var delegate: TabViewProviderDelegate?
  private var props = TabViewProps()
  private var hostingController: PlatformHostingController<TabViewImpl>?
  private var coalescingKey: UInt16 = 0
  private var iconSize = CGSize(width: 27, height: 27)

  @objc var onPageSelected: RCTDirectEventBlock?

  @objc var onTabLongPress: RCTDirectEventBlock?
  @objc var onTabBarMeasured: RCTDirectEventBlock?
  @objc var onNativeLayout: RCTDirectEventBlock?

  @objc public var icons: NSArray? {
    didSet {
      loadIcons(icons, focused: false)
    }
  }

  @objc public var focusedIcons: NSArray? {
    didSet {
      loadIcons(focusedIcons, focused: true)
    }
  }

  @objc public var sidebarAdaptable: Bool = false {
    didSet {
      props.sidebarAdaptable = sidebarAdaptable
    }
  }

  @objc public var disablePageAnimations: Bool = false {
    didSet {
      props.disablePageAnimations = disablePageAnimations
    }
  }

  @objc public var labeled: Bool = false {
    didSet {
      props.labeled = labeled
    }
  }

  @objc public var selectedPage: NSString? {
    didSet {
      props.selectedPage = selectedPage as? String
    }
  }

  @objc public var hapticFeedbackEnabled: Bool = false {
    didSet {
      props.hapticFeedbackEnabled = hapticFeedbackEnabled
    }
  }

  @objc public var layoutDirection: NSString? {
    didSet {
      props.layoutDirection = layoutDirection as? String
    }
  }
  @objc public var scrollEdgeAppearance: NSString? {
    didSet {
      props.scrollEdgeAppearance = scrollEdgeAppearance as? String
    }
  }

  @objc public var minimizeBehavior: NSString? {
    didSet {
      props.minimizeBehavior = MinimizeBehavior(rawValue: minimizeBehavior as? String ?? "")
    }
  }

  @objc public var translucent: Bool = true {
    didSet {
      props.translucent = translucent
    }
  }

  @objc public var barTintColor: PlatformColor? {
    didSet {
      props.barTintColor = barTintColor
    }
  }

  @objc public var activeTintColor: PlatformColor? {
    didSet {
      props.activeTintColor = activeTintColor
    }
  }

  @objc public var inactiveTintColor: PlatformColor? {
    didSet {
      props.inactiveTintColor = inactiveTintColor
    }
  }

  @objc public var experimentalBakedTintColors: Bool = false {
    didSet {
      props.experimentalBakedTintColors = experimentalBakedTintColors
    }
  }

  @objc public var fontFamily: NSString? {
    didSet {
      props.fontFamily = fontFamily as? String
    }
  }

  @objc public var fontWeight: NSString? {
    didSet {
      props.fontWeight = fontWeight as? String
    }
  }

  @objc public var fontSize: NSNumber? {
    didSet {
      props.fontSize = fontSize as? Int
    }
  }

  @objc public var tabBarHidden: Bool = false {
    didSet {
      props.tabBarHidden = tabBarHidden
    }
  }

  @objc public var itemsData: [TabInfo] = [] {
    didSet {
      props.items = itemsData
    }
  }

  @objc public convenience init(delegate: TabViewProviderDelegate) {
    self.init()
    self.delegate = delegate
  }

  @objc public func setImageLoader(_ imageLoader: RCTImageLoader) {
    self.imageLoader = imageLoader
    loadIcons(icons, focused: false)
    loadIcons(focusedIcons, focused: true)
  }

  override public func didUpdateReactSubviews() {
    props.children = reactSubviews().map(IdentifiablePlatformView.init)
  }

#if os(macOS)
  override public func layout() {
    super.layout()
    setupView()
  }
#else
  override public func layoutSubviews() {
    super.layoutSubviews()
    setupView()
  }
#endif

  private func setupView() {
    if self.hostingController != nil {
      return
    }

    self.hostingController = PlatformHostingController(rootView: TabViewImpl(props: props) { key in
      self.delegate?.onPageSelected(key: key, reactTag: self.reactTag)
    } onLongPress: { key in
      self.delegate?.onLongPress(key: key, reactTag: self.reactTag)
    } onLayout: { size  in
      self.delegate?.onLayout(size: size, reactTag: self.reactTag)
    } onTabBarMeasured: { height in
      self.delegate?.onTabBarMeasured(height: height, reactTag: self.reactTag)
    })

    if let hostingController = self.hostingController, let parentViewController = reactViewController() {
      parentViewController.addChild(hostingController)
#if !os(macOS)
      hostingController.view.backgroundColor = .clear
#endif
      addSubview(hostingController.view)
      hostingController.view.translatesAutoresizingMaskIntoConstraints = false
      hostingController.view.pinEdges(to: self)
#if !os(macOS)
      hostingController.didMove(toParent: parentViewController)
#endif
    }
  }

  @objc(insertChild:atIndex:)
  public func insertChild(_ child: PlatformView, at index: Int) {
    guard index >= 0 && index <= props.children.count else {
      return
    }
    props.children.insert(IdentifiablePlatformView(child), at: index)
  }

  @objc(removeChildAtIndex:)
  public func removeChild(at index: Int) {
    guard index >= 0 && index < props.children.count else {
      return
    }
    props.children.remove(at: index)
  }

  private func loadIcons(_ icons: NSArray?, focused: Bool) {
    guard let imageLoader else { return }

    // TODO: Diff the arrays and update only changed items.
    // Now if the user passes `unfocusedIcon` we update every item.
    if let imageSources = icons as? [RCTImageSource?] {
      for (index, imageSource) in imageSources.enumerated() {
        guard let imageSource else { continue }

        #if RN_BOTTOM_TABS_ENABLE_SVG
          if SVGIconLoader.isSVGRequest(imageSource.request) {
            loadSVGIcon(
              with: imageSource.request,
              at: index,
              focused: focused,
              failureMessage: "Error loading SVG icon"
            )
            continue
          }
        #endif

        imageLoader.loadImage(
          with: imageSource.request,
          size: imageSource.size,
          scale: imageSource.scale,
          clipped: true,
          resizeMode: RCTResizeMode.contain,
          progressBlock: { _, _ in },
          partialLoad: { _ in },
          completionBlock: { [weak self] error, image in
            self?.handleLoadedIcon(
              image,
              error: error,
              request: imageSource.request,
              at: index,
              focused: focused
            )
          }
        )
      }
    }
  }
}

private extension TabViewProvider {
  func handleLoadedIcon(
    _ image: PlatformImage?,
    error: Error?,
    request: URLRequest,
    at index: Int,
    focused: Bool
  ) {
    if let error {
      #if RN_BOTTOM_TABS_ENABLE_SVG
        loadSVGIcon(
          with: request,
          at: index,
          focused: focused,
          failureMessage: "Error loading image: \(error.localizedDescription)"
        )
      #else
        print("[TabView] Error loading image: \(error.localizedDescription)")
      #endif
      return
    }
    guard let image else { return }
    updateIcon(image, at: index, focused: focused)
  }

  func updateIcon(_ image: PlatformImage, at index: Int, focused: Bool) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let icon = image.resizeImageTo(size: iconSize)
      #if os(iOS)
        if props.experimentalBakedTintColors {
          if focused {
            props.focusedIcons[index] = icon?.withRenderingMode(.alwaysTemplate)
          } else {
            props.icons[index] = icon?.withRenderingMode(.alwaysTemplate)
          }
        } else {
          if focused {
            props.focusedIcons[index] = icon
          } else {
            props.icons[index] = icon
          }
        }
        props.iconsRevision += 1
      #else
        if focused {
          props.focusedIcons[index] = icon
        } else {
          props.icons[index] = icon
        }
        props.iconsRevision += 1
      #endif
    }
  }

  #if RN_BOTTOM_TABS_ENABLE_SVG
    func loadSVGIcon(
      with request: URLRequest,
      at index: Int,
      focused: Bool,
      failureMessage: String
    ) {
      SVGIconLoader.decode(with: request) { [weak self] image in
        guard let self else { return }
        if let image {
          updateIcon(image, at: index, focused: focused)
        } else {
          print("[TabView] \(failureMessage)")
        }
      }
    }
  #endif
}
