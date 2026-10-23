#if RN_BOTTOM_TABS_ENABLE_SVG
  import Foundation
  #if SWIFT_PACKAGE
    import BottomTabsSVG
  #endif

  /// Loads SVG tab icons with the opt-in CoreSVG decoder.
  enum SVGIconLoader {
    static func isSVGRequest(_ request: URLRequest) -> Bool {
      guard let url = request.url else { return false }
      return url.pathExtension.lowercased() == "svg"
        || url.absoluteString.lowercased().hasPrefix("data:image/svg+xml")
    }

    static func decode(
      with request: URLRequest,
      completion: @escaping (PlatformImage?) -> Void
    ) {
      guard let url = request.url else {
        completion(nil)
        return
      }

      let decode: (Data?) -> Void = { data in
        guard let data else {
          completion(nil)
          return
        }
        completion(RNBottomTabsDecodeSVGData(data))
      }

      if url.scheme == "http" || url.scheme == "https" {
        let task = URLSession.shared.dataTask(with: request) { data, _, _ in
          decode(data)
        }
        task.resume()
      } else {
        DispatchQueue.global(qos: .userInitiated).async {
          decode(try? Data(contentsOf: url))
        }
      }
    }
  }
#endif
