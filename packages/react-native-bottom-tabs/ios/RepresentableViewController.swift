import Foundation
import SwiftUI

/**
 Helper used to render UIViewController inside of SwiftUI.
 This solves issues in some cases that can't found root UINavigationController.
 */
struct RepresentableViewController: UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    
  }
  
  
  var view: PlatformView
  
#if os(macOS)
  
  func makeNSView(context: Context) -> PlatformView {
    let wrapper = NSView()
    wrapper.addSubview(view)
    return wrapper
  }
  
  func updateNSView(_ nsView: PlatformView, context: Context) {}
  
#else
  
  func makeUIView(context: Context) -> PlatformView {
    let wrapper = UIView()
    wrapper.addSubview(view)
    return wrapper
  }
  func makeUIViewController(context: Context) -> UIViewController {
    let contentVC = UIViewController()
    contentVC.view.backgroundColor = .clear
    contentVC.view.addSubview(view)
    
    return contentVC
  }
  func updateUIView(_ uiView: PlatformView, context: Context) {}
  
#endif
}
