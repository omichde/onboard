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
	
	@IBOutlet weak var starsView: SKView!
	
	private let starScene = SKScene(size: .zero)
	private var starEmitter: SKEmitterNode?

	override func viewDidLoad() {
		super.viewDidLoad()

		starScene.backgroundColor = .clear
		starScene.scaleMode = .resizeFill
		starsView.presentScene(starScene)

		guard let emitter = SKEmitterNode(fileNamed: "OnboardFinalStar") else { return }
		starScene.addChild(emitter)
		starEmitter = emitter
		updateStarsLayout()
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		updateStarsLayout()
	}
}

private extension OnboardFinalViewController {
	func updateStarsLayout() {
		let size = starsView.bounds.size
		guard size.width > 0, size.height > 0 else { return }

		starScene.size = size
		starEmitter?.position = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
		starEmitter?.particlePositionRange = CGVector(dx: size.width * 0.5, dy: size.height * 0.5)
	}
}
