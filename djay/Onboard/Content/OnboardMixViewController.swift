//
//  OnboardMixViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit

// The second page contains 3 images.
class OnboardMixViewController: OnboardContentViewController {
	
	@IBOutlet weak var heroView: UIImageView!
	@IBOutlet weak var mixLabel: UILabel!
	@IBOutlet weak var adaView: UIImageView!

	private var heroAnimator: Animator?
	private var mixAnimator: Animator?
	private var adaAnimator: Animator?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		guard heroAnimator == nil else { return }
		heroAnimator = Animator(
			progress: onboard.progressPublisher,
			view: heroView,
			steps: [
				AnimatorStep(
					progress: 0.5,
					transform: CGAffineTransform(translationX: -view.bounds.width * 0.5, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0),
				AnimatorStep(
					progress: 1,
					transform: .identity,
					alpha: 1),
				AnimatorStep(
					progress: 1.5,
					transform: CGAffineTransform(translationX: view.bounds.width * 0.5, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0)
			]
		)

		mixAnimator = Animator(
			progress: onboard.progressPublisher,
			view: mixLabel,
			steps: [
				AnimatorStep(
					progress: 0.6,
					transform: CGAffineTransform(translationX: -view.bounds.width * 0.4, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0),
				AnimatorStep(
					progress: 1,
					transform: .identity,
					alpha: 1),
				AnimatorStep(
					progress: 1.4,
					transform: CGAffineTransform(translationX: view.bounds.width * 0.4, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0)
			]
		)

		adaAnimator = Animator(
			progress: onboard.progressPublisher,
			view: adaView,
			steps: [
				AnimatorStep(
					progress: 0.7,
					transform: CGAffineTransform(translationX: -view.bounds.width * 0.3, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0),
				AnimatorStep(
					progress: 1,
					transform: .identity,
					alpha: 1),
				AnimatorStep(
					progress: 1.3,
					transform: CGAffineTransform(translationX: view.bounds.width * 0.3, y: 30).scaledBy(x: 0.1, y: 0.1),
					alpha: 0)
			]
		)
	}

}
