//
//  AudioController.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 30/01/2024.
//

import Foundation
import AudioKit


import AudioToolbox



@MainActor class AudioController:  HasAudioEngine, ObservableObject {
	
	let engine = AudioEngine()
	//let initialDevice: Device
	var playerA = AudioPlayer()
	var mixer:Mixer!
	var t:RepeatingTimer!
	@Published var currentPoint:[CGPoint] = []
	var visionPoints:[CGPoint]?{
		didSet{
			//print(visionPoints?.debugDescription)
			if let  v = visionPoints{
				currentPoint = v
			}
			
		}
	}
	
	
	init(){
		
		print("from here")
		
		//Settings.ioBufferDuration = 0.0001
		//guard let input = engine.input else { fatalError() }
		//guard let device = engine.inputDevice else { fatalError() }
		//initialDevice = device
		

		
//		t = RepeatingTimer(timeInterval: 0.05)
//		t.eventHandler = {
//			//print("Timer Fired")
//		}
//		t.resume()
		loadPlayer()
		mixer = Mixer(playerA)
		engine.output = mixer
		
		try? engine.start()
		playerA.play()
	}

	func loadPlayer(){
		
		let urlA = Bundle.main.url(forResource:"A0", withExtension: "wav")!
		do {
			try playerA.load(url: urlA, buffered: false)
			playerA.isLooping = true
			//try playerB.load(url: urlB, buffered: false)
			//playerB.isLooping = true
			//try playerC.load(url: urlC, buffered: false)
			//playerC.isLooping = true
			//player.isBuffered = true
		} catch {
			Log(error.localizedDescription, type: .error)
		}
	}
	
	
}
