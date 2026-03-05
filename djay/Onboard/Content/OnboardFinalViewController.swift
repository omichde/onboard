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
	@IBOutlet weak var logoView: UIImageView!
	@IBOutlet weak var heroView: UIImageView!
	@IBOutlet weak var featuresLabel: UILabel!
	
	private let starSingleScene = SKScene(size: .zero)
	private let starDoubleScene = SKScene(size: .zero)
	private var starSingleEmitter: SKEmitterNode?
	private var starDoubleEmitter: SKEmitterNode?
	private var logoAnimator: Animator?
	private var heroAnimator: Animator?
	private var featuresAnimator: Animator?
	private var lastSize: CGSize = .zero
	
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

		guard view.bounds.size != lastSize else { return }
		lastSize = view.bounds.size

		logoAnimator = Animator(
			progress: onboard.progressPublisher,
			view: logoView,
			keyframes: [2.5, 2.9, 3, 3.1, 3.5],
			stateProvider: { progress, _ in
				switch progress {
				case 2.5, 3.5:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.2, y: 0.2),
						alpha: 0.5)
				case 2.9, 3.1:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: 0).scaledBy(x: 1.1, y: 1.1),
						alpha: 1)
				default:
					return Animator.State.default
				}
			}
		)

		heroAnimator = Animator(
			progress: onboard.progressPublisher,
			view: heroView,
			keyframes: [2.5, 3, 3.5],
			stateProvider: { progress, _ in
				switch progress {
				case let p where p < 3:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: 30).scaledBy(x: 0.5, y: 0.5),
						alpha: 0.5)
				case let p where p > 3:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: 100).scaledBy(x: 0.3, y: 0.3),
						alpha: 0.5)
				default:
					return Animator.State.default
				}
			}
		)

		featuresAnimator = Animator(
			progress: onboard.progressPublisher,
			view: featuresLabel,
			keyframes: [2.5, 3, 3.5],
			stateProvider: { progress, _ in
				switch progress {
				case 2.5, 3.5:
					return Animator.State(alpha: 0.5)
				default:
					return Animator.State.default
				}
			}
		)
	}
}

private extension OnboardFinalViewController {
	func updateStarsLayout() {
		let size = starsSingleView.bounds.size
		guard size.width > 0, size.height > 0 else { return }
		let position = CGPoint(x: size.width * 0.5, y: size.height * 0.5 - 10)
		let range = CGVector(dx: size.width * 0.5, dy: size.height * 0.5)

		starSingleScene.size = size
		starSingleEmitter?.position = position
		starSingleEmitter?.particlePositionRange = range

		starDoubleScene.size = size
		starDoubleEmitter?.position = position
		starDoubleEmitter?.particlePositionRange = range
	}
}
