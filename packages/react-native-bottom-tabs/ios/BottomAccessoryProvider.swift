import SwiftUI

@objc public class BottomAccessoryProvider: NSObject {
  private weak var delegate: BottomAccessoryProviderDelegate?

  @objc public convenience init(delegate: BottomAccessoryProviderDelegate) {
    self.init()
    self.delegate = delegate
  }

  #if !os(macOS)
  @available(iOS 26.0, tvOS 26.0, *)
  public func emitPlacementChanged(_ placement: TabViewBottomAccessoryPlacement?) {
    var placementValue = "none"
    if placement == .inline {
      placementValue = "inline"
    } else if placement == .expanded {
      placementValue = "expanded"
    }
    self.delegate?.onPlacementChanged(placement: placementValue)
  }
  #endif
}

@objc public protocol BottomAccessoryProviderDelegate {
  func onPlacementChanged(placement: String)
}
