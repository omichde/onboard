//
//  State.swift
//  djay
//
//  Created by Oliver Michalak on 05.03.26.
//

import UIKit


extension Animator {
	// The payload for an animation is held in here.
	struct State {
		// The transform being applied to the view.
		let transform: CGAffineTransform
		
		// The alpha for the view.
		let alpha: CGFloat
		
		init(transform: CGAffineTransform = .identity, alpha: CGFloat = 1) {
			self.transform = transform
			self.alpha = alpha
		}

		static let `default` = State()

		// A lense to easily compose states.
		func with(transform: CGAffineTransform? = nil, alpha: CGFloat? = nil) -> State {
			State(transform: transform ?? self.transform, alpha: alpha ?? self.alpha)
		}
	}
}
