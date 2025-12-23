import Foundation
import React
import SwiftUI

@objcMembers
public final class TabInfo: NSObject {
  public let key: String
  public let title: String
  public let badge: String?
  public let sfSymbol: String
  public let activeTintColor: PlatformColor?
  public let hidden: Bool
  public let testID: String?
  public let role: TabBarRole?
  public let preventsDefault: Bool

  public init(
    key: String,
    title: String,
    badge: String?,
    sfSymbol: String,
    activeTintColor: PlatformColor?,
    hidden: Bool,
    testID: String?,
    role: String?,
    preventsDefault: Bool = false
  ) {
    self.key = key
    self.title = title
    self.badge = badge
    self.sfSymbol = sfSymbol
    self.activeTintColor = activeTintColor
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
      loadIcons(icons)
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
    loadIcons(icons)
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

  private func loadIcons(_ icons: NSArray?) {
    guard let imageLoader else { return }

    // TODO: Diff the arrays and update only changed items.
    // Now if the user passes `unfocusedIcon` we update every item.
    if let imageSources = icons as? [RCTImageSource?] {
      for (index, imageSource) in imageSources.enumerated() {
        guard let imageSource else { continue }
        imageLoader.loadImage(
          with: imageSource.request,
          size: imageSource.size,
          scale: imageSource.scale,
          clipped: true,
          resizeMode: RCTResizeMode.contain,
          progressBlock: { _, _ in },
          partialLoad: { _ in },
          completionBlock: { error, image in
            if error != nil {
              print("[TabView] Error loading image: \(error!.localizedDescription)")
              return
            }
            guard let image else { return }
            DispatchQueue.main.async { [weak self] in
              guard let self else { return }
              props.icons[index] = image.resizeImageTo(size: iconSize)
            }
          })
      }
    }
  }
}
