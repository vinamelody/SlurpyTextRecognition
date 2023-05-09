import UIKit
import VisionKit
import SwiftUI

class ScannerViewController: UIViewController {
  
  var dataScanner: DataScannerViewController?
  var alertHost: UIViewController?
  let overlay = PaintingViewController()
  
  var isScanningSupported: Bool {
    DataScannerViewController.isSupported
  }
  
  var isScanningAvailable: Bool {
    DataScannerViewController.isAvailable
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    installDataScanner()
  }
  
  func installDataScanner() {
    guard dataScanner == nil else { return }
    
    guard isScanningSupported else {
      installNoScanOverlay()
      return
    }
    guard isScanningAvailable else {
      installNoPermissionOverlay()
      return
    }
    
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
  
  func installNoScanOverlay() {
    let scanNotSupported = FullScreenBanner(
      systemImageName: "exclamationmark.octagon.fill",
      mainText: "Scanner not supported on this device",
      detailText: "You need a device with a camera and an A12 Bionic processor or better (Late 2017)",
      backgroundColor: .red)
    installOverlay(fullScreenBanner: scanNotSupported)
  }
  
  func installNoPermissionOverlay() {
    let noCameraPermission = FullScreenBanner(
      systemImageName: "video.slash",
      mainText: "Camera permission not granted",
      detailText: "Go to Settings to grant permission to use the camera",
      backgroundColor: .orange)
    installOverlay(fullScreenBanner: noCameraPermission)
  }
  
  private func installOverlay(fullScreenBanner: FullScreenBanner) {
    cleanHost()
    let host = UIHostingController(rootView: fullScreenBanner)
    view.pinToInside(host.view)
    alertHost = host
  }
  
  func cleanHost() {
    alertHost?.view.removeFromSuperview()
    alertHost = nil
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
