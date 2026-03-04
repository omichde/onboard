//
//  OnboardWelcomeViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit


// The first page contains the welcome message only, because the logo,
// step button and page indicator are global.
class OnboardWelcomeViewController: OnboardContentViewController {
	
	@IBOutlet weak var welcomeLabel: UILabel!

	private var welcomeAnimator: Animator?

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		guard welcomeAnimator == nil else { return }
		welcomeAnimator = Animator(
			progress: onboard.progressPublisher,
			view: welcomeLabel,
			steps: [
				AnimatorStep(
					progress: -0.5,
					transform: CGAffineTransform(translationX: -view.bounds.width * 0.5, y: 0),
					alpha: 0),
				AnimatorStep(
					progress: 0,
					transform: CGAffineTransform(translationX: 0, y: -100),
					alpha: 1),
				AnimatorStep(
					progress: 0.5,
					transform: CGAffineTransform(translationX: view.bounds.width * 0.5, y: 0),
					alpha: 0)
			]
		)

		// if it appears for the first time, fade in the welcome label
		onboard.progress = -0.5
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		onboard.setProgress(0, animated: true)
	}
}

