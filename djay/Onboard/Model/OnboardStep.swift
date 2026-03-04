//
//  OnboardStep.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import Foundation


enum OnboardStep: Int, CaseIterable {
	case welcome, mix, skill, final
}

extension OnboardStep {
	/// The view controller type for each page.
	var pageClass: OnboardContentViewController.Type {
		switch self {
		case .welcome:
			OnboardWelcomeViewController.self
		case .mix:
			OnboardMixViewController.self
		default:
			OnboardContentViewController.self
		}
	}
	
	/// The button title for each pages.
	var stepTitle: String {
		switch self {
		case .welcome, .mix, .skill:
			NSLocalizedString("Continue", comment: "Continue button in onboarding")
		case .final:
			NSLocalizedString("Let's go", comment: "Final button text in onboarding")
		}
	}
}
