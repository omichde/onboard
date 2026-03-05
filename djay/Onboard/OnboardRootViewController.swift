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
/// The root VC's safe area contains the scroll view, which is then responsible
/// for embedding all page view controllers.
class OnboardRootViewController: UIViewController {
	
	let onboard = Onboard()
	private static let djayURL = URL(string: "djay://")
	
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
			keyframes: [0, 1, 2],
			stateProvider: { progress, view in
				switch progress {
				case 1:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: view.traitCollection.verticalSizeClass == .compact ? -60 : -140),
						alpha: 1)
				case 2:
					return Animator.State(
						transform: CGAffineTransform(translationX: 0, y: view.traitCollection.verticalSizeClass == .compact ? -60 : -140).scaledBy(x: 0.1, y: 0.1),
						alpha: 0)
				default:
					return Animator.State(
						transform: .identity,
						alpha: 1)
				}
			}
		)

		// Update the step button title and pager for the current step.
		onboard.stepPublisher
			.removeDuplicates()
			.sink { [weak self] step in
				self?.pageIndicator.currentPage = step.rawValue
				self?.stepButton.setTitle(step.stepTitle, for: .normal)
			}
			.store(in: &bag)
		
		// Update the step button according to the current progress.
		onboard.progressPublisher.combineLatest(onboard.skillPublisher)
			.sink { [weak self] (progress, skill) in
				guard let self else { return }
				
				// Disable the Continue button if no skill is selected.
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
		guard onboard.step != .final else {
			// at the end, launch the real djay app
			if let url = Self.djayURL,
				 UIApplication.shared.canOpenURL(url) {
				UIApplication.shared.open(url)
			}
			return
		}
		onboard.setProgress(onboard.progress + 1, animated: true)
	}
	
	@IBAction func selectPage() {
		onboard.setProgress(Float(pageIndicator.currentPage), animated: true)
		// meh: although this is called on `.valueChanged` of the pageIndicator, resetting the value directly has no effect.
		// Dispatching to the next UIKit event loop is required for a proper update.
		// Why reset? If the user tries to step past the skill barrier,
		// the control allows it, but `onboard` remains the source of truth.
		DispatchQueue.main.async { [weak self] in
			guard let self else { return }
			self.pageIndicator.currentPage = self.onboard.step.rawValue
		}
	}
}
