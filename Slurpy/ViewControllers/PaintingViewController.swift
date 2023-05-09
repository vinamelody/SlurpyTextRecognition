import UIKit
import SwiftUI

/// highlights objects in the camera view
class PaintingViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let paintController = UIHostingController(rootView: Highlighter().environmentObject(DataStore.shared))
    paintController.view.backgroundColor = .clear
    view.pinToInside(paintController.view)
    addChild(paintController)
    paintController.didMove(toParent: self)
  }
}
