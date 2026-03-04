//
//  OnboardContentViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit


class OnboardContentViewController: UIViewController {
	var onboard: Onboard!
}

extension OnboardContentViewController {
	class func instantiate(onboard: Onboard) -> Self {
		let resolvedBundle = Bundle(for: self)
		let resolvedNibName = String(describing: self)
		let nib = UINib(nibName: resolvedNibName, bundle: resolvedBundle)

		guard let controller = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
			fatalError("Failed to instantiate \(resolvedNibName) as \(self)")
		}
		controller.onboard = onboard
		return controller
	}
}
