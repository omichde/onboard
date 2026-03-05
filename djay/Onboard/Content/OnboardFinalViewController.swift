//
//  OnboardFinalViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import SpriteKit


// The fourth screen contains the final content of the onboarding flow.
class OnboardFinalViewController: OnboardContentViewController {
	
	@IBOutlet weak var starsSingleView: SKView!
	@IBOutlet weak var starsDoubleView: SKView!

	private let starSingleScene = SKScene(size: .zero)
	private let starDoubleScene = SKScene(size: .zero)
	private var starSingleEmitter: SKEmitterNode?
	private var starDoubleEmitter: SKEmitterNode?

	override func viewDidLoad() {
		super.viewDidLoad()

		starSingleScene.backgroundColor = .clear
		starSingleScene.scaleMode = .resizeFill
		starsSingleView.presentScene(starSingleScene)

		starDoubleScene.backgroundColor = .clear
		starDoubleScene.scaleMode = .resizeFill
		starsDoubleView.presentScene(starDoubleScene)

		if let emitter = SKEmitterNode(fileNamed: "OnboardFinalStar"),
			 let image = UIImage(named: "note-single") {
			starSingleScene.addChild(emitter)
			emitter.particleTexture = SKTexture(image: image)
			starSingleEmitter = emitter
		}
		if let emitter = SKEmitterNode(fileNamed: "OnboardFinalStar"),
			 let image = UIImage(named: "note-double") {
			starDoubleScene.addChild(emitter)
			emitter.particleTexture = SKTexture(image: image)
			starDoubleEmitter = emitter
		}

		updateStarsLayout()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateStarsLayout()
	}
}

private extension OnboardFinalViewController {
	func updateStarsLayout() {
		let size = starsSingleView.bounds.size
		guard size.width > 0, size.height > 0 else { return }

		starSingleScene.size = size
		let position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
		let range = CGVector(dx: size.width * 0.5, dy: size.height * 0.5)
		starSingleEmitter?.position = position
		starSingleEmitter?.particlePositionRange = range

		starDoubleScene.size = size
		starDoubleEmitter?.position = position
		starDoubleEmitter?.particlePositionRange = range
	}
}
