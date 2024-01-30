

import SwiftUI

struct CameraView: UIViewControllerRepresentable {
  var pointsProcessorHandler: (([CGPoint]) -> Void)?

  func makeUIViewController(context: Context) -> CameraViewController {
    let cvc = CameraViewController()
    cvc.pointsProcessorHandler = pointsProcessorHandler
    return cvc
  }

  func updateUIViewController(
    _ uiViewController: CameraViewController,
    context: Context
  ) {
  }
	
}
