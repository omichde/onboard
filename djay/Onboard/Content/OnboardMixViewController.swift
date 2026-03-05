//
//  OnboardMixViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit

// The second page contains three images.
class OnboardMixViewController: OnboardContentViewController {
	
	@IBOutlet weak var heroView: UIImageView!
	@IBOutlet weak var mixLabel: UILabel!
	@IBOutlet weak var adaView: UIImageView!

	private var heroAnimator: Animator?
	private var mixAnimator: Animator?
	private var adaAnimator: Animator?
	private var lastSize: CGSize = .zero
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		guard view.bounds.size != lastSize else { return }
		lastSize = view.bounds.size

		heroAnimator = Animator(
			progress: onboard.progressPublisher,
			view: heroView,
			keyframes: [0.5, 1, 1.5],
			stateProvider: { progress, view in
				let defaultState = Animator.State(transform: .identity, alpha: 1)
				guard let pageWidth = view.parentViewController?.view.bounds.width,
							let containerWidth = view.superview?.bounds.width
				else { return defaultState }
				let factor = containerWidth / pageWidth

				switch progress {
				case let p where p < 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * -0.5, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				case let p where p > 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * 0.5, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				default:
					return defaultState
				}
			}
		)

		mixAnimator = Animator(
			progress: onboard.progressPublisher,
			view: mixLabel,
			keyframes: [0.6, 1, 1.4],
			stateProvider: { progress, view in
				let defaultState = Animator.State(transform: .identity, alpha: 1)
				guard let pageWidth = view.parentViewController?.view.bounds.width,
							let containerWidth = view.superview?.bounds.width
				else { return defaultState }
				let factor = containerWidth / pageWidth

				switch progress {
				case let p where p < 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * -0.4, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				case let p where p > 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * 0.4, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				default:
					return defaultState
				}
			}
		)

		adaAnimator = Animator(
			progress: onboard.progressPublisher,
			view: adaView,
			keyframes: [0.7, 1, 1.3],
			stateProvider: { progress, view in
				let defaultState = Animator.State(transform: .identity, alpha: 1)
				guard let pageWidth = view.parentViewController?.view.bounds.width,
							let containerWidth = view.superview?.bounds.width
				else { return defaultState }
				let factor = containerWidth / pageWidth

				switch progress {
				case let p where p < 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * -0.3, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				case let p where p > 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * 0.3, y: 30).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				default:
					return defaultState
				}
			}
		)
	}
}
