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
				let defaultState = Animator.State(
					transform: CGAffineTransform(translationX: 0, y: view.traitCollection.verticalSizeClass == .compact ? -180 : -80),
					alpha: 1
				)
				
				// The view should strictly animate in vertical direction only,
				// but as this view controller is embedded into a scroll view, we need
				// to compensate the horizontal scroll view movement by inverting the views
				// x-position. This is based on the page base view width and the views
				// container width.
				// We could have avoided that calculation by keeping the view outside the
				// page and place it globally onto the root view controller, but that would
				// flood the root view with all animations. Furthermore it feels more natural
				// and better isolated to keep the messageLabel in here.
				guard let pageWidth = view.parentViewController?.view.bounds.width,
							let containerWidth = view.superview?.bounds.width
				else { return defaultState }
				
				let factor = containerWidth / pageWidth

				switch progress {
				case let p where p < 0:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * -0.5, y: 0),
						alpha: 0)
				case let p where p > 0:
					return Animator.State(
						transform: CGAffineTransform(translationX: containerWidth / factor * 0.5, y: 0),
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
