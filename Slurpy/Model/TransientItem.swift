/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import VisionKit

struct TransientItem: Identifiable, Equatable {
  var id: UUID { item.id }
  let item: RecognizedItem

  var textContent: String? {
    switch item {
    case .text(let rtext):
      return rtext.transcript
    case .barcode(let barcode):
      return barcode.payloadStringValue
    @unknown default:
      return nil
    }
  }

  static func == (lhs: TransientItem, rhs: TransientItem) -> Bool {
    lhs.id == rhs.id
  }

  var isText: Bool {
    switch item {
    case .text:
      return true
    default:
      return false
    }
  }

  var isBarcode: Bool {
    switch item {
    case .barcode:
      return true
    default:
      return false
    }
  }

  /// convert `VKRect` to a `CGRect`
  var bounds: CGRect {
    let vkrect = item.bounds
    let width = vkrect.topRight.x - vkrect.topLeft.x
    let height = vkrect.bottomRight.y - vkrect.topRight.y
    return CGRect(
      x: vkrect.topLeft.x + width / 2,
      y: vkrect.topLeft.y + height / 2,
      width: width,
      height: height
    )
  }
}

extension TransientItem {
  var icon: String {
    if isText {
      return "text.bubble"
    } else {
      return "barcode"
    }
  }
}

extension TransientItem {
  func toStoredItem() -> StoredItem {
    return StoredItem(
      id: id,
      string: textContent,
      type: isBarcode ? .barcode:.text,
      barcodeSymbology: {
        switch item {
        case .barcode(let barcode):
          return barcode.observation.symbology.rawValue
        default:
          return nil
        }
      }()
    )
  }
}
