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
	private var lastSize: CGSize = .zero
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		guard view.bounds.size != lastSize else { return }
		lastSize = view.bounds.size
		
		// Rebuild on size/orientation changes.
		welcomeAnimator = Animator(
			progress: onboard.progressPublisher,
			view: welcomeLabel,
			keyframes: [-0.5, 0, 0.5],
			stateProvider: { progress, view in
				let defaultState = Animator.State(transform: CGAffineTransform(translationX: 0, y: -100), alpha: 1)
				guard let pageWidth = view.superview?.bounds.width
				else { return defaultState }

				switch progress {
				case let p where p < 0:
					return Animator.State(
						transform: CGAffineTransform(translationX: pageWidth * -0.5, y: 0),
						alpha: 0)
				case let p where p > 0:
					return Animator.State(
						transform: CGAffineTransform(translationX: pageWidth * 0.5, y: 0),
						alpha: 0)
				default:
					return defaultState
				}
			}
		)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// If it appears for the first time, offset the welcome label and...
		onboard.progress = -0.5
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		// fade in the welcome label once
		onboard.setProgress(0, animated: true)
	}
}
