//
//  Animator.swift
//  djay
//
//  Created by Oliver Michalak on 04.03.26.
//

import UIKit
import Combine


// To transition UIViews between pages, this small helper class drives a UIView
// transform and alpha according to its progress value, define in a `AnimatorStep`.
//
class Animator {
	
	// The incoming progress value.
	let progress: AnyPublisher<Float, Never>
	
	// The view in question we animate.
	let view: UIView
	
	// The steps/keyframe with define the transition.
	let steps: [AnimatorStep]

	// The currently active segment.
	// A segment is the transition between two neighbouring steps.
	private var activeSegmentIndex: Int?
	
	// The currently active UIKit animator.
	// Multiple animators on one view can produce strange results,
	// so we keep only one alive.
	private var activeAnimator: UIViewPropertyAnimator?
	
	private var cancellable: AnyCancellable?
	
	init?(progress: AnyPublisher<Float, Never>, view: UIView, steps: [AnimatorStep]) {
		self.progress = progress
		self.view = view
		self.steps = steps.sorted { $0.progress < $1.progress }
		self.activeSegmentIndex = nil
		self.activeAnimator = nil
		
		guard isValid else { return nil }
		
		view.transform = self.steps[0].transform
		view.alpha = CGFloat(self.steps[0].alpha)
		
		self.cancellable = progress.sink { [weak self] progress in
			self?.applyProgress(progress)
		}
	}
	
	private var isValid: Bool {
		steps.count >= 2
	}
	
	private func applyProgress(_ progress: Float) {
		guard let segment = segment(for: progress) else { return }
		animator(for: segment.index)
		activeAnimator?.fractionComplete = segment.fraction
	}
	
	private func segment(for progress: Float) -> (index: Int, fraction: CGFloat)? {
		let lastSegmentIndex = steps.count - 2
		guard lastSegmentIndex >= 0 else { return nil }

		// assuming sorted step, we use the start of the first step or...
		if progress <= steps[0].progress {
			return (index: 0, fraction: 0)
		}
		// the end of the last segment for out-of-bounds progress values
		if progress >= steps[steps.count - 1].progress {
			return (index: lastSegmentIndex, fraction: 1)
		}
		
		for i in 0...lastSegmentIndex {
			let start = steps[i].progress
			let end = steps[i + 1].progress
			guard progress >= start, progress <= end else { continue }
			
			let span = end - start
			let fraction = CGFloat((progress - start) / span)
			return (index: i, fraction: fraction)
		}
		
		return nil
	}
	
	private func animator(for segmentIndex: Int) {
		guard activeSegmentIndex != segmentIndex || activeAnimator == nil else { return }
		
		activeAnimator?.stopAnimation(true)
		
		let start = steps[segmentIndex]
		let end = steps[segmentIndex + 1]
		view.transform = start.transform
		view.alpha = CGFloat(start.alpha)
		
		let duration = TimeInterval(end.progress - start.progress)
		let animator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak view] in
			view?.transform = end.transform
			view?.alpha = CGFloat(end.alpha)
		}
		animator.pausesOnCompletion = true
		animator.startAnimation()
		animator.pauseAnimation()
		animator.fractionComplete = 0
		
		activeSegmentIndex = segmentIndex
		activeAnimator = animator
	}
}

struct AnimatorStep {
	let progress: Float
	let transform: CGAffineTransform
	let alpha: Float
}
