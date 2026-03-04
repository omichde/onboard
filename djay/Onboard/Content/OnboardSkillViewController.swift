//
//  OnboardSkillViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import Combine

// The third screen asks the user for their skill level.
// This is a barrier screen, the user must not be able to progress further without an answer.
class OnboardSkillViewController: OnboardContentViewController {

	@IBOutlet private weak var newSkillButton: UIButton!
	@IBOutlet private weak var normalSkillButton: UIButton!
	@IBOutlet private weak var professionalSkillButton: UIButton!
	
	private var bag = Set<AnyCancellable>()
		
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		guard bag.isEmpty
		else { return }
		
		let buttons: [UIButton] = [newSkillButton, normalSkillButton, professionalSkillButton]
		for button in buttons {
			button.configurationUpdateHandler = { [weak self] button in
				self?.configure(button: button, selected: button.isSelected)
			}
			button.setNeedsUpdateConfiguration()
		}

		onboard.skillPublisher
			.sink { [weak self] skill in
				self?.newSkillButton.isSelected = (skill == .new)
				self?.normalSkillButton.isSelected = (skill == .normal)
				self?.professionalSkillButton.isSelected = (skill == .professional)
				buttons.forEach { $0.setNeedsUpdateConfiguration() }
			}
			.store(in: &bag)
	}
}

private extension OnboardSkillViewController {

	@IBAction func selectSkill(_ sender: UIButton) {
		onboard.skill = switch sender {
		case newSkillButton: .new
		case normalSkillButton: .normal
		case professionalSkillButton: .professional
		default: nil
		}
	}

	// Since iOS 15, button appearance can be customized with `UIButton.Configuration`.
	// This creates a configuration matching the design spec: a left-side selection icon,
	// a left-aligned title, and a border.
	func configure(button: UIButton, selected: Bool) {
		var config = button.configuration ?? .gray()
		if config.title == nil {
			config.title = button.title(for: .normal)
		}
		
		config.titleAlignment = .leading
		config.imagePlacement = .leading
		config.imagePadding = 16
		config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
		config.titleLineBreakMode = .byTruncatingTail
		config.image = UIImage(named: selected ? "checkbox/on" : "checkbox/off")
		
		var background = config.background
		background.backgroundColor = UIColor(named: "Text/Quarternary")
		background.strokeWidth = selected ? 2 : 0
		background.strokeColor = selected ? UIColor(named: "AccentColor") : .clear
		config.background = background
		
		button.configuration = config
	}
}
