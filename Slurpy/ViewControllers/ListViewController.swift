import UIKit
import SwiftUI

/// shows a list of the items you have collected
class ListViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let datastore = DataStore.shared
    let listController = UIHostingController(rootView: ListOfThings().environmentObject(datastore))
    view.pinToInside(listController.view)
    addChild(listController)
    listController.didMove(toParent: self)
  }
  
}
