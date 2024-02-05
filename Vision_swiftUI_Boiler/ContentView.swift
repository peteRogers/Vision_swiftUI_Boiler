//
//  ContentView.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 07/12/2022.
//

import SwiftUI

struct ContentView: View {
   
	@ObservedObject var ac = AudioController()
    var body: some View {
        ZStack{
            CameraView{
				ac.visionPoints = $0
            }.overlay(
				PointsOverlay(with: ac.currentPoints)
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
