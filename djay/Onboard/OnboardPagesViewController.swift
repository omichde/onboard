//
//  OnboardPagesViewController.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import Combine


/// The pages the user can swipe through are embedded into a horizontal
/// UIScrollView, its setup and handling is the core of this view controller.
/// One could create and embed this VC in the Onboard.storyboard, but and empty scroll view
/// confuses IB and produces useless warnings.
/// Visually, the borderless scroll view creates pages, each of the same size as the scroll
/// view and placed horizontally next to each other.
class OnboardPagesViewController: UIViewController {
	
	var onboard: Onboard!
	
	private lazy var pages: [OnboardContentViewController] = []

	// To prevent some jitter during scroll interaction.
	private static let barrierOffsetEpsilon: CGFloat = 0.5

	private let scrollView = UIScrollView()
	private var bag = Set<AnyCancellable>()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// set up scroll view and its page containers
		setupScrollView()
		embedPages()
		view.layoutIfNeeded()

		// adjust onboard model
		onboard.pageCount = pages.count
		onboard.skillBarrierIndex = OnboardStep.skill.rawValue
		applyProgress(onboard.progress)

		// scroll to appropriate page depending on progress,
		// but only if we do not scroll interactively!
		onboard.progressPublisher
			.sink { [weak self] progress in
				guard let self,
							!self.scrollView.isTracking,
							!self.scrollView.isDragging,
							!self.scrollView.isDecelerating
				else { return }
				self.applyProgress(progress)
			}
			.store(in: &bag)
	}
	
	private func setupScrollView() {
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.isPagingEnabled = true
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.bounces = true
		scrollView.delegate = self

		view.addSubview(scrollView)
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: view.topAnchor),
			scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
		])
	}
	
	private func embedPages() {
		var previousContainer: UIView?
		
		for page in pages {
			let pageContainer = UIView()
			pageContainer.translatesAutoresizingMaskIntoConstraints = false
			scrollView.addSubview(pageContainer)
			
			NSLayoutConstraint.activate([
				pageContainer.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
				pageContainer.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
				pageContainer.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
				pageContainer.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
			])
			
			if let previousContainer {
				pageContainer.leadingAnchor.constraint(equalTo: previousContainer.trailingAnchor).isActive = true
			} else {
				pageContainer.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor).isActive = true
			}
			
			page.embed(into: pageContainer)
			previousContainer = pageContainer
		}
		
		previousContainer?.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor).isActive = true
	}
	
	private func applyProgress(_ progress: Float) {
		guard !pages.isEmpty, scrollView.bounds.width > 0 else { return }
		
		let maxProgress = Float(pages.count - 1)
		let clampedProgress = max(0, min(progress, maxProgress))
		let x = CGFloat(clampedProgress) * scrollView.bounds.width
		
		if abs(scrollView.contentOffset.x - x) < Self.barrierOffsetEpsilon { return }
		
		scrollView.contentOffset = CGPoint(x: x, y: scrollView.contentOffset.y)
	}

	// In order to prevent interactive scrolling beyond the allowed skill barrier
	// we calculate `barrierX` as a maximum allowed scroll view content offset.
	private var barrierX: CGFloat {
		CGFloat(onboard.skillBarrierIndex) * scrollView.bounds.width
	}

	// Strictly blocking the scrolling beyond the barrier would feel unnatural,
	// but then we need to snap back in case the user is beyond it.
	@discardableResult
	private func snapBackToBarrierIfNeeded(animated: Bool) -> Bool {
		guard onboard.isSkillBarrierActive, scrollView.bounds.width > 0 else { return false }
		guard scrollView.contentOffset.x > barrierX + Self.barrierOffsetEpsilon else { return false }
		scrollView.setContentOffset(CGPoint(x: barrierX, y: scrollView.contentOffset.y), animated: animated)
		return true
	}
}

extension OnboardPagesViewController: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		guard onboard.isSkillBarrierActive, scrollView.bounds.width > 0 else { return }
		if targetContentOffset.pointee.x > barrierX + Self.barrierOffsetEpsilon {
			targetContentOffset.pointee.x = barrierX
		}
	}

	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard !snapBackToBarrierIfNeeded(animated: true) else { return }
		let index = Int(scrollView.progress.rounded())
		onboard.progress = Float(index)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		guard !decelerate,
					!snapBackToBarrierIfNeeded(animated: true)
		else { return }
		let index = Int(scrollView.progress.rounded())
		onboard.progress = Float(index)
	}
	
	func scrollViewDidScroll(_ scrollView: UIScrollView) {
		guard scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating else { return }
		onboard.progress = scrollView.progress
	}
}


fileprivate extension UIScrollView {
	// Map the scroll position back to a `progress` compatible value.
	var progress: Float {
		guard bounds.width > 0 else { return 0 }
		return Float(contentOffset.x / bounds.width)
	}
}
