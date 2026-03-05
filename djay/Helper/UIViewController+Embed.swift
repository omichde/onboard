//
//  UIViewController+Embed.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit


extension UIViewController {
	/// Embed `self` as a child view controller into a `container` view.
	public func embed(into container: UIView) {
		guard let parentViewController = container.parentViewController
		else { return }

		container.translatesAutoresizingMaskIntoConstraints = false
		self.view.translatesAutoresizingMaskIntoConstraints = false
		
		self.view.frame = container.bounds
		parentViewController.addChild(self)
		container.addSubview(self.view)
		
		NSLayoutConstraint.activate([
			container.topAnchor.constraint(equalTo: self.view.topAnchor),
			container.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			container.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			container.leftAnchor.constraint(equalTo: self.view.leftAnchor)
		])
		
		self.didMove(toParent: parentViewController)
	}
}


extension UIView {
	/// Find the (next) parent view controller for a given view.
	var parentViewController: UIViewController? {
		if let nextResponder = self.next as? UIViewController {
			return nextResponder
		}
		else if let nextResponder = self.next as? UIView {
			return nextResponder.parentViewController
		}
		else {
			return nil
		}
	}
}
