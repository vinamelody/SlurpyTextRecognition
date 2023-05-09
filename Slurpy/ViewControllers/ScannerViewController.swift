import UIKit
import VisionKit

class ScannerViewController: UIViewController {
  
  var dataScanner: DataScannerViewController?
  
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
    
    do {
      try scanner.startScanning()
    } catch {
      print("Error: Unable to start scan. \(error)")
    }
  }
}

extension ScannerViewController: DataScannerViewControllerDelegate {
  
  func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didUpdate updatedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didRemove removedItems: [RecognizedItem], allItems: [RecognizedItem]) {
    
  }
  
  func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
    
  }
}

extension DataScannerViewController {
  static func makeDatascanner(delegate: DataScannerViewControllerDelegate) -> DataScannerViewController {
    let scanner = DataScannerViewController(recognizedDataTypes: [.text()], isGuidanceEnabled: true, isHighlightingEnabled: true)
    scanner.delegate = delegate
    return scanner
  }
}
