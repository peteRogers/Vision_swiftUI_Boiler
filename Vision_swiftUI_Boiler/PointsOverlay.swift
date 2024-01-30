
import SwiftUI

struct PointsOverlay: Shape {
  let points: [CGPoint]
  

  init(with points: [CGPoint]) {
    self.points = points
  }

  func path(in rect: CGRect) -> Path {
	let pointsPath = UIBezierPath()
    for point in points {
      pointsPath.move(to: point)
      pointsPath.addArc(withCenter: point, radius: 15, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    }

    return Path(pointsPath.cgPath)
  }
}
