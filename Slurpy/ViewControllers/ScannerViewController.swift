import UIKit
import VisionKit

class ScannerViewController: UIViewController {
  
  var dataScanner: DataScannerViewController?
  let overlay = PaintingViewController()
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    installDataScanner()
  }
  
  func installDataScanner() {
    guard dataScanner == nil else { return }
    
    let scanner = DataScannerViewController.makeDatascanner(delegate: self)
    dataScanner = scanner
    addChild(scanner)
    view.pinToInside(scanner.view)
    
    addChild(scanner)
    scanner.didMove(toParent: self)
    scanner.overlayContainerView.pinToInside(overlay.view)
    
    do {
      try scanner.startScanning()
    } catch {
      print("Error: Unable to start scan. \(error)")
    }
  }
}

extension ScannerViewController: DataScannerViewControllerDelegate {
  
  func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    DataStore.shared.addThings(
      addedItems.map { TransientItem(item: $0) },
      allItems: allItems.map { TransientItem(item: $0) }
    )
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    DataStore.shared.updateThings(
      updatedItems.map { TransientItem(item: $0) },
      allItems: allItems.map { TransientItem(item: $0) }
    )
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    DataStore.shared.removeThings(
      removedItems.map { TransientItem(item: $0) },
      allItems: allItems.map { TransientItem(item: $0) }
    )
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
    DataStore.shared.keepItem(TransientItem(item: item).toStoredItem())
  }
}

extension DataScannerViewController {
  static func makeDatascanner(delegate: DataScannerViewControllerDelegate) -> DataScannerViewController {
    let scanner = DataScannerViewController(recognizedDataTypes: [.text()], isGuidanceEnabled: true, isHighlightingEnabled: false)
    scanner.delegate = delegate
    return scanner
  }
}
