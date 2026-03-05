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
		case .skill:
			OnboardSkillViewController.self
		case .final:
			OnboardFinalViewController.self
		}
	}
	
	/// The button title for each page.
	var stepTitle: String {
		switch self {
		case .welcome, .mix:
			NSLocalizedString("Continue", comment: "Continue button in onboarding")
		case .skill:
			NSLocalizedString("Let's go", comment: "Skill confirmation button text in onboarding")
		case .final:
			NSLocalizedString("Done", comment: "Final button in onboarding")
		}
	}
}
