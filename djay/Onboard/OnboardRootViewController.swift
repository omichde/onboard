//
//  OnboardRootViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import Combine


/// The root view controller, starting the whole onboarding flow.
/// It owns the `Onboard` model, embeds the `OnboardPagesViewController` and
/// controls the "global" views (logo, step button, page indicator),
/// which are visible on top of all the specialized pages and their view controllers.
/// Visually the safe areas of the root VC will embed the scroll view, which
/// is later responsible to embed all pages accordingly.
class OnboardRootViewController: UIViewController {
	
	let onboard = Onboard()
	
	@IBOutlet weak var logoView: UIImageView!
	@IBOutlet weak var stepButton: UIButton!
	@IBOutlet weak var pagesContainer: UIView!
	@IBOutlet weak var pageIndicator: UIPageControl!
	
	private var animator: Animator?
	private var bag = Set<AnyCancellable>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let pagesViewController = OnboardPagesViewController()
		pagesViewController.onboard = onboard
		pagesViewController.embed(into: pagesContainer)
		
		pageIndicator.numberOfPages = onboard.pageCount
		animator = Animator(
			progress: onboard.progressPublisher,
			view: logoView,
			steps: [
				AnimatorStep(
					progress: 0,
					transform: .identity,
					alpha: 1),
				AnimatorStep(
					progress: 1,
					transform: CGAffineTransform(translationX: 0, y: -140),
					alpha: 1),
				AnimatorStep(
					progress: 2,
					transform: CGAffineTransform(translationX: 0, y: -140).scaledBy(x: 0.1, y: 0.1),
					alpha: 0)
			]
		)

		// adjust the step button title and pager depending on the step
		onboard.stepPublisher
			.removeDuplicates()
			.sink { [weak self] step in
				self?.pageIndicator.currentPage = step.rawValue
				self?.stepButton.setTitle(step.stepTitle, for: .normal)
			}
			.store(in: &bag)
		
		// adjust the step button according to the progress
		onboard.progressPublisher.combineLatest(onboard.skillPublisher)
			.sink { [weak self] (progress, skill) in
				guard let self else { return }
				
				// disabled continue button if no skill was selected
				let isEnabled = if !onboard.isSkillBarrierActive {
					true
				} else {
					(progress <= Float(OnboardStep.mix.rawValue))
				}
				self.stepButton.isUserInteractionEnabled = isEnabled
				self.stepButton.alpha = isEnabled ? 1 : 0.3
			}
			.store(in: &bag)
	}
	
	@IBAction func step() {
		onboard.setProgress(onboard.progress + 1, animated: true)
	}
	
	@IBAction func selectPage() {
		onboard.setProgress(Float(pageIndicator.currentPage), animated: true)
		// meh: although this is called on `.valueChanged`, resetting the value directly has no effect.
		// We must dispatch it to the next event loop in UIKit for proper updates.
		// Why the reset? If the user tries to step ahead beyond the skill barrier,
		// the control does allow it, but `onboard` holds the truth.
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			self.pageIndicator.currentPage = self.onboard.step.rawValue
		}
	}
}
