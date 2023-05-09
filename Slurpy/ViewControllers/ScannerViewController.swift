import AVFoundation
import CoreHaptics
import SwiftUI
import UIKit
import VisionKit

class ScannerViewController: UIViewController {
  
  var dataScanner: DataScannerViewController?
  var alertHost: UIViewController?
  let overlay = PaintingViewController()
  var feedbackPlayer: AVAudioPlayer?
  
  let hapticEngine: CHHapticEngine? = {
    do {
      let engine = try CHHapticEngine()
      engine.notifyWhenPlayersFinished { _ in
        return .stopEngine
      }
      return engine
    } catch {
      print("Haptics are not working. \(error)")
      return nil
    }
  }()
  
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
  
  func uninstallDataScanner() {
    guard let dataScanner else { return }
    dataScanner.stopScanning()
    dataScanner.view.removeFromSuperview()
    dataScanner.removeFromParent()
    self.dataScanner = nil
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    uninstallDataScanner()
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
    playHapticClick()
  }
}

extension DataScannerViewController {
  static func makeDatascanner(delegate: DataScannerViewControllerDelegate) -> DataScannerViewController {
    let scanner = DataScannerViewController(recognizedDataTypes: [.text()], isGuidanceEnabled: true, isHighlightingEnabled: false)
    scanner.delegate = delegate
    return scanner
  }
}

extension ScannerViewController {
  func hapticPattern() throws -> CHHapticPattern {
    let events = [
      CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [],
        relativeTime: 0,
        duration: 0.25
        ),
      CHHapticEvent(
        eventType: .hapticTransient,
        parameters: [],
        relativeTime: 0.25,
        duration: 0.5)
    ]
    let pattern = try CHHapticPattern(events: events, parameters: [])
    return pattern
  }
  
  func playHapticClick() {
    guard let hapticEngine else { return }
    
    guard UIDevice.current.userInterfaceIdiom == .phone else { return }
    
    do {
      try hapticEngine.start()
      let pattern = try hapticPattern()
      let player = try hapticEngine.makePlayer(with: pattern)
      try player.start(atTime: 0)
    } catch {
      print("Haptic error: \(error)")
    }
  }
}

extension ScannerViewController {
  func playFeedbackSound() {
    guard let url = Bundle.main.url(forResource: "WAV_Jinja", withExtension: "wav") else {
      return
    }
    
    do {
      feedbackPlayer = try AVAudioPlayer(contentsOf: url)
      feedbackPlayer?.play()
    } catch {
      print("Error playing sound: \(error)")
    }
  }
}
