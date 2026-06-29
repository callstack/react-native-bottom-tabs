import Foundation
import SwiftUI

internal enum MinimizeBehavior: String {
  case automatic
  case never
  case onScrollUp
  case onScrollDown

  #if compiler(>=6.2)
    @available(iOS 26.0, macOS 26.0, tvOS 26.0, *)
    func convert() -> TabBarMinimizeBehavior {
      #if os(macOS) || os(tvOS)
        return .automatic
      #else
        switch self {
        case .automatic:
          return .automatic
        case .never:
          return .never
        case .onScrollUp:
          return .onScrollUp
        case .onScrollDown:
          return .onScrollDown
        }
      #endif
    }
  #endif
}

public enum TabBarRole: String {
  case search

  @available(iOS 18, macOS 15, visionOS 2, tvOS 18, *)
  func convert() -> TabRole {
    switch self {
    case .search:
      return .search
    }
  }
}

struct IdentifiablePlatformView: Identifiable, Equatable {
  let id = UUID()
  let view: PlatformView

  init(_ view: PlatformView) {
    self.view = view
  }
}

/// Props that component accepts. SwiftUI view gets re-rendered when ObservableObject changes.
class TabViewProps: ObservableObject {
  @Published var children: [IdentifiablePlatformView] = []
  @Published var items: [TabInfo] = []
  @Published var selectedPage: String?
  @Published var icons: [Int: PlatformImage] = [:]
  @Published var focusedIcons: [Int: PlatformImage] = [:]
  @Published var iconsRevision: Int = 0
  @Published var sidebarAdaptable: Bool?
  @Published var labeled: Bool = false
  @Published var minimizeBehavior: MinimizeBehavior?
  @Published var scrollEdgeAppearance: String?
  @Published var barTintColor: PlatformColor?
  @Published var activeTintColor: PlatformColor?
  @Published var inactiveTintColor: PlatformColor?
  @Published var experimentalBakedTintColors: Bool = false
  @Published var translucent: Bool = true
  @Published var disablePageAnimations: Bool = false
  @Published var hapticFeedbackEnabled: Bool = false
  @Published var layoutDirection: String?
  @Published var fontSize: Int?
  @Published var fontFamily: String?
  @Published var fontWeight: String?
  @Published var tabBarHidden: Bool = false

  var selectedActiveTintColor: PlatformColor? {
    if let selectedPage,
      let tabData = items.findByKey(selectedPage),
      let activeTintColor = tabData.activeTintColor
    {
      return activeTintColor
    }

    return activeTintColor
  }

  var hasCustomTintColors: Bool {
    activeTintColor != nil
      || inactiveTintColor != nil
      || items.contains(where: { $0.activeTintColor != nil })
  }

  var effectiveInactiveTintColor: PlatformColor? {
    #if os(iOS)
      if ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26 {
        return nil
      }
    #endif

    return inactiveTintColor
  }

  var filteredItems: [TabInfo] {
    items.filter {
      !$0.hidden || $0.key == selectedPage
    }
  }
}
