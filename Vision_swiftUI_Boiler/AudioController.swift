//
//  AudioController.swift
//  Vision_swiftUI_Boiler
//
//  Created by Peter Rogers on 30/01/2024.
//

import Foundation
import AudioKit
import SoundpipeAudioKit
import AudioToolbox
import Vision
import DunneAudioKit
import AudioKitEX


@MainActor class AudioController:  HasAudioEngine, ObservableObject {
	
	let engine = AudioEngine()
	var playerA = AudioPlayer()
	var mixer:Mixer!
	var wah:AutoWah!
	var chorus: Chorus!
	var dryWetMixer: DryWetMixer!
	var flanger: Flanger!
	@Published var currentPoints:[MyJoint] = []
	
	var visionPoints:[MyJoint]?{
		didSet{
			if let  v = visionPoints{
				currentPoints = v
				manipulateAudio()
			}
			else{
				print("nothing detected")
			}
		}
	}
	
	
	init(){
		loadPlayer()
//		wah = AutoWah(playerA)
//		wah.wah = 0
//		wah.amplitude = 0.1
		
		chorus = Chorus(playerA)
		flanger = Flanger(chorus)
		//dryWetMixer = DryWetMixer(playerA, chorus)
		mixer = Mixer(flanger)
		//mixer.volume = 0
		engine.output = mixer
		try? engine.start()
		playerA.play()
	}
	
	func manipulateAudio(){
		if(currentPoints.count > 0){
			if let ls = currentPoints.first(where: { $0.visionPoint.identifier == 
				VNHumanBodyPoseObservation.JointName.leftShoulder.rawValue}) {
				if let lw = currentPoints.first(where: { $0.visionPoint.identifier == VNHumanBodyPoseObservation.JointName.leftWrist.rawValue}) {
					let an = angleBetweenPoints(point1: ls.imagePoint!, point2: lw.imagePoint!)
					var vol = map(value: an * 180 / .pi, fromSourceRange: (min: -40.0, max:40.0), toDestinationRange: (min: 0.0, max:10.0))
					//vol = constrain(value: vol, floor: 0.0, ceiling: 1.0)
					//mixer.volume = AUValue(1)
					chorus.frequency = AUValue(vol)
					chorus.dryWetMix = 1
					chorus.depth = 1
					chorus.feedback = 1.0
					
				}else{
					chorus.dryWetMix = 0
					flanger.dryWetMix = 0
				}
			}else{
				chorus.dryWetMix = 0
				   flanger.dryWetMix = 0
			   }
			
			if let rs = currentPoints.first(where: { $0.visionPoint.identifier == VNHumanBodyPoseObservation.JointName.rightShoulder.rawValue}) {
				if let rw = currentPoints.first(where: { $0.visionPoint.identifier == VNHumanBodyPoseObservation.JointName.rightWrist.rawValue}) {
					let an = angleBetweenPoints(point1: rs.imagePoint!, point2: rw.imagePoint!)
					var vol = map(value: an * 180 / .pi, fromSourceRange: (min: -40.0, max:40.0), toDestinationRange: (min: 0.0, max:10.0))
					//vol = constrain(value: vol, floor: 0.0, ceiling: 1.0)
					//mixer.volume = AUValue(1)
					flanger.frequency = AUValue(vol)
					
					flanger.dryWetMix = 1
					flanger.depth = 1
					flanger.feedback = 1.0
					
				}else{
					chorus.dryWetMix = 0
					flanger.dryWetMix = 0
				}
			}else{
				chorus.dryWetMix = 0
				   flanger.dryWetMix = 0
			   }
		}else{
			chorus.dryWetMix = 0
			flanger.dryWetMix = 0
		}
//		if wah != nil{
//			if(currentPoints.count > 0){
//				let v = currentPoints[0]
//				let out = Float(v.imagePoint!.x / 1920.0)
//				wah!.wah = out*2.0
//				//print(out)
//				
//			}
//		}
	}
	
	func angleBetweenPoints(point1: CGPoint, point2: CGPoint) -> CGFloat {
		let deltaX = point2.x - point1.x
		let deltaY = point2.y - point1.y
		return atan2(deltaY, deltaX)
	}
	
	func map(value: CGFloat, fromSourceRange sourceRange: (min: CGFloat, max: CGFloat), toDestinationRange destinationRange: (min: CGFloat, max: CGFloat)) -> CGFloat {
		// First, normalize the value to a 0 to 1 range (relative to the source range)
		let normalized = (value - sourceRange.min) / (sourceRange.max - sourceRange.min)
		// Then, map the normalized value to the destination range
		return normalized * (destinationRange.max - destinationRange.min) + destinationRange.min
	}
	
	func constrain(value: CGFloat, floor: CGFloat, ceiling: CGFloat) -> CGFloat{
		var out = value
		if out > ceiling {
			out = ceiling
		}
		if(out < floor){
			out = floor
		}
		return out
	}


	func loadPlayer(){
		let urlA = Bundle.main.url(forResource:"drums", withExtension: "wav")!
		do {
			try playerA.load(url: urlA, buffered: false)
				playerA.isLooping = true
		} catch {
			Log(error.localizedDescription, type: .error)
		}
	}
}
