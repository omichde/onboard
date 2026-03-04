//
//  OnboardContentViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit


/// The base class for all content/pages view controllers.
/// All pages need `Onboard`, but each keeps its content isolated in its own XIB.
class OnboardContentViewController: UIViewController {
	var onboard: Onboard!
}

extension OnboardContentViewController {
	// Create a view controller from its type name and set up
	// the model as early as possible.
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
