//
//  ContentView.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 07/12/2022.
//

import SwiftUI

struct ContentView: View {
   // @State private var overlayPoints: [CGPoint] = []
	@ObservedObject var ac = AudioController()
    var body: some View {
        ZStack{
            CameraView{
				ac.visionPoints = $0
                
            }.overlay(
				PointsOverlay(with: ac.currentPoint)
                    .foregroundColor(.red)
              )
              .edgesIgnoringSafeArea(.all)
			
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


